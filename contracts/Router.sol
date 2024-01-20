// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./Vault.sol";
// import "./interfaces/IRouter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

import "./interfaces/IVault.sol";
import "./Messenger.sol";

contract Router is Messenger, ERC721 {

    // user -> vaultAddress -> vault
    // mapping(address => mapping(address => IVault)) public userVaults;

    IPool public pool;
    address public facilitator;
    uint64 public destinationChainSelector;

    mapping (bytes32 => bytes) public messages;

    constructor(uint64 _destinationChainSelector, address _pool, address _router, address _link) Messenger(_router, _link) {
      pool = IPool(_pool);
      destinationChainSelector = _destinationChainSelector;
    }

    function supportsInterface(bytes4 interfaceId) public pure override(CCIPReceiver, ERC721) returns (bool) {
        return CCIPReceiver.supportsInterface(interfaceId) || ERC721.supportsInterface(interfaceId);
    }

    function updateGhoulFacilitator(address _facilitator) onlyOwner public {
      facilitator = _facilitator;
    }

    function createVault() public {
        // require(address(userVaults[msg.sender]) == address(0), "Vault already exists");
        // Vault newVault = new Vault(pool, messenger, facilitator, liquidator);
        // newVault.transferOwnership(msg.sender);
        // userVaults[msg.sender].push(newVault);
        // emit VaultCreated(msg.sender, address(newVault));
    }

    function getVault(uint256 index) public view returns (IVault) {
        // return userVaults[msg.sender][index];
    }

    function initBorrow(
      address _vault, 
      uint256 _amount
    ) external {
      // Make sure msg.sender is owner of Vault
      address _borrower = msg.sender;

      IVault vault = IVault(_vault);
      uint256 totalDebtBase = vault.getTotalDebtBase();

      uint256 _totalCollateralBase;
      uint256 _totalDebtBase;
      uint256 _availableBorrowsBase;
      uint256 _currentLiquidationThreshold;
      uint256 _ltv;
      uint256 _healthFactor;

      (_totalCollateralBase, _totalDebtBase, _availableBorrowsBase, _currentLiquidationThreshold, _ltv, _healthFactor) = pool.getUserAccountData(_vault);

      require((_totalCollateralBase * 10000) < (totalDebtBase * _ltv), "UnderCollateralized");

      sendMessagePayLINK(destinationChainSelector, facilitator, BORROW, _borrower, _vault, _amount, address(0));
    }

    // function initRepay(
    //   address _vault,
    //   uint256 _amount
    // ) external {
    //   // Make sure msg.sender is owner of Vault
    //   address _borrower = msg.sender;

    //   IVault vault = IVault(_vault);
    //   uint256 totalDebtBase = vault.getTotalDebtBase();

    //   require(amount )

    //   sendMessagePayLINK(destinationChainSelector, facilitator, REPAY, _borrower, _vault, _amount, address(0));
    // }

    function _repay(address _borrower, address _vault, uint256 _amount) internal {
        // Change the base debt! make sure it's converted to 8 decimals instead of default 18 decimals (divide by 10)

    }

    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    )
        internal
        override
    {
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
            _repay(borrower, vault, amount);
        }
    }

    // function liquidate(
    //   address borrower,
    //   address vault,
    //   uint256 amount,
    //   address liquidator
    // ) external;
}
