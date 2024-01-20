// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {Vault} from "./Vault.sol";
import {IRouter} from "./interfaces/IRouter.sol";
import {IVault} from  "./interfaces/IVault.sol";
import {Messenger} from "./Messenger.sol";
import {CCIPReceiver} from "./ccip/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";


contract Router is Messenger, ERC721 {
    IPool public pool;
    address public facilitator;
    uint64 public destChainSelector;

    mapping (bytes32 => bytes) public messages;

    // Vault => GHO debts
    mapping (address => uint256) public debts;

    constructor(uint64 _destChainSelector, address _pool, address _router, address _link) ERC721("GhoulRouter", "GHOUL") Messenger(_router, _link)  {
      pool = IPool(_pool);
      destChainSelector = _destChainSelector;
    }


    function supportsInterface(bytes4 interfaceId) public virtual view override(CCIPReceiver, ERC721) returns (bool) {
        return CCIPReceiver.supportsInterface(interfaceId) || ERC721.supportsInterface(interfaceId);
    }

    function updateGhoulFacilitator(address _facilitator) onlyOwner public {
      facilitator = _facilitator;
    }

    function updateGhoulPool(address _pool) onlyOwner public {
      pool = IPool(_pool);
    }

    function createVault() public {
        Vault vault = new Vault();
        uint256 vaultId = uint256(uint160(address(vault)));

        _safeMint(msg.sender, vaultId);
    }

    modifier onlyVaultOwner(address _vault) {
        uint256 vaultId = uint256(uint160(_vault));
        require(_isApprovedOrOwner(_msgSender(), vaultId), "ERC721: caller is not token owner nor approved");
        _;
    }

    function withdraw(address _vault, address token, uint256 amount) public onlyVaultOwner(_vault) {
        IVault vault = IVault(_vault);
        vault.withdraw(payable(_msgSender()), token, amount);
    }

    function getVaultData(address _vault) public view returns(uint256 totalCollateralBase, uint256 totalDebtBase, uint256 ltv) {
      uint256 _totalDebtBase;
      uint256 _availableBorrowsBase;
      uint256 _currentLiquidationThreshold;
      uint256 _healthFactor;

      (totalCollateralBase, _totalDebtBase, _availableBorrowsBase, _currentLiquidationThreshold, ltv, _healthFactor) = pool.getUserAccountData(_vault);
      totalDebtBase = debts[_vault] / (10 ** 10);
    }

    modifier onlyOverCollateralized(address _vault) {
      uint256 _totalCollateralBase;
      uint256 _totalDebtBase;
      uint256 _ltv;
      (_totalCollateralBase, _totalDebtBase, _ltv) = getVaultData(_vault);
      require((_totalCollateralBase * 10000) < (_totalDebtBase * _ltv), "UnderCollateralized");
      _;
    }

    function initBorrow(
      address _vault,
      uint256 _amount
    ) external onlyVaultOwner(_vault) onlyOverCollateralized(_vault) {
      address _borrower = _msgSender();

      // Change debt for the Vault
      debts[_vault] += _amount;

      sendMessagePayLINK(destChainSelector, facilitator, BORROW, _borrower, _vault, _amount, address(0));
    }

    function _repay(address _vault, uint256 _amount) internal {
        // If repaid amount is greater than debt; reset debt to zero
        if(debts[_vault] < _amount) {
          debts[_vault] = 0;
        }
        debts[_vault] -= _amount;
    }

    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        messages[any2EvmMessage.messageId] = any2EvmMessage.data;

        uint8 operationType;
        address borrower;
        address vault;
        uint256 amount;
        address liquidator;

        (operationType, borrower, vault, amount, liquidator) = abi.decode(any2EvmMessage.data, (uint8, address, address, uint256, address));

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            operationType,
            borrower,
            vault,
            amount,
            liquidator
        );

        if (operationType == REPAY) {
            _repay(vault, amount);
        }
    }
}
