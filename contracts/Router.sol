// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./Vault.sol";
// import "./interfaces/IRouter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";

import "./interfaces/IVault.sol";
import "./Messenger.sol";

contract Router is Ownable, ERC721 {

    // user -> vaultAddress -> vault
    // mapping(address => mapping(address => IVault)) public userVaults;

    IPool public pool;
    address public facilitator;
    Messenger public messenger;
    uint64 public destinationChainSelector;

    constructor(uint64 _destinationChainSelector, address _pool, address _router, address _link) {
      pool = IPool(_pool);
      messenger = new Messenger(_router, _link);
      destinationChainSelector = _destinationChainSelector;
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

    function borrow(
      address _vault, 
      uint256 _amount
    ) external {
      // Make sure msg.sender is owner of Vault

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

      address _borrower = msg.sender;

      messenger.sendMessagePayLINK(destinationChainSelector, facilitator, BORROW, _borrower, _vault, _amount, address(0));
    }

    function repay(
      address borrower,
      address vault,
      uint256 amount
    ) external;

    function liquidate(
      address borrower,
      address vault,
      uint256 amount,
      address liquidator
    ) external;
}
