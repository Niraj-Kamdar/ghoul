// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "./interfaces/IVaultFactory.sol";
import "./interfaces/IVault.sol";

contract Vault is IVault {
  address public owner;
  IVaultFactory public factory;
  IPool public pool;
  uint256 public totalDebtBase; // 8 decimal total borrowed gho

  constructor(address _owner, address _pool) {
    owner = _owner;
    pool = IPool(_pool);
  }

  function withdraw(address token, uint256 amount) public {
    require(msg.sender == owner, "Only owner can withdraw");
    require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    emit Withdrawn(token, amount);
  }

  function borrow(uint256 amount) public {
    uint256 _totalCollateralBase;
    uint256 _totalDebtBase;
    uint256 _availableBorrowsBase;
    uint256 _currentLiquidationThreshold;
    uint256 _ltv;
    uint256 _healthFactor;
    
    require(msg.sender == owner, "Only owner can borrow");
    (
      _totalCollateralBase,
      _totalDebtBase,
      _availableBorrowsBase,
      _currentLiquidationThreshold,
      _ltv,
      _healthFactor
    ) = pool.getUserAccountData(msg.sender);

    // Update the total Debt
    totalDebtBase += (amount / 10 ** 10); 
    // Check if position under collateralized after update
    require(_isUndercollateralized(_totalCollateralBase, _ltv) == false, "UnderCollateralized: Borrow cancelled");

    // Send CCIP mint GHO message
  }

  function _isUndercollateralized(uint256 totalCollateralBase, uint256 ltv) internal view returns (bool) {
    return (totalCollateralBase * 10000) < (totalDebtBase * ltv);
  }
}
