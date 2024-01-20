// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vault.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IVault.sol";
import "./Messenger.sol";
import "./lib/Encoder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Router is IRouter, Ownable, ERC721 {

    // user -> vault token id -> vault
    mapping(address => mapping(uint256 => IVault)) public userVaults;

    uint256 public nextVaultId = 1;

    address public pool;
    address public facilitator;
    address public liquidator;
    Messenger public messenger;

    constructor(address _pool, address _facilitator, address _liquidator, address _router, address _link) ERC721("GhoulRouter", "GHOUL") {
      pool = _pool;
      facilitator = _facilitator;
      liquidator = _liquidator;
      messenger = new Messenger(address(this), msg.sender, _router, _link);
    }

    function supportsInterface(bytes4 interfaceId) public pure override(CCIPReceiver, ERC721) returns (bool) {
        return CCIPReceiver.supportsInterface(interfaceId) || ERC721.supportsInterface(interfaceId);
    }

    function updateGhoulFacilitator(address _facilitator) onlyOwner public {
      facilitator = _facilitator;
    }

    function updateGhoulLiquidator(address _liquidator) onlyOwner public {
      liquidator = _liquidator;
    }

    function updateGhoulPool(address _pool) onlyOwner public {
      pool = _pool;
    }

    function createVault() public {
        Vault newVault = new Vault(address(this), pool, messenger, facilitator, liquidator);
        uint256 vaultId = nextVaultId;
        nextVaultId++;
        require(address(userVaults[msg.sender][vaultId]) == address(0), "Vault already exists");
        userVaults[msg.sender][vaultId] = newVault;
        _safeMint(msg.sender, vaultId);
        emit VaultCreated(msg.sender, vaultId, address(newVault));
    }

    function getVault(uint256 vaultId) public view returns (IVault) {
        return userVaults[msg.sender][vaultId];
    }

    function borrow(uint256 vaultId, uint256 amount, uint64 destChainSelector) public returns (bytes32 messageId) {
        IVault vault = userVaults[msg.sender][vaultId];
        require(address(vault) != address(0), "Vault not created!");
        return vault.borrow(msg.sender, amount, destChainSelector);
    }

    function withdraw(uint256 vaultId, address token, uint256 amount) public {
        IVault vault = userVaults[msg.sender][vaultId];
        require(address(vault) != address(0), "Vault not created!");
        vault.withdraw(payable(msg.sender), token, amount);
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
