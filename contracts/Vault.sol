// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "./interfaces/IVaultFactory.sol";
import "./interfaces/IVault.sol";
import "./Messenger.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vault is IVault, Ownable {
  uint256 public destChainSelector = 12532609583862916517;

  IVaultFactory public factory;
  IPool public pool;
  Messenger public messenger;
  address public facilitator;
  address public liquidator;

  uint256 public totalDebtBase = 0; // 8 decimal total borrowed gho

  constructor(address _pool, Messenger _messenger, address _facilitator, address _liquidator) {
    pool = IPool(_pool);
    messenger = _messenger;
    facilitator = _facilitator;
    liquidator = _liquidator;
  }

  function withdraw(address token, uint256 amount) onlyOwner public {
    if (token == address(0)) {
      require(msg.sender.transfer(amount), "Transfer failed");
    } else {
      require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    }
    emit Withdrawn(token, amount);
  }

  function borrow(uint256 amount) onlyOwner public returns (bytes32 messageId) {
    uint256 _totalCollateralBase;
    uint256 _totalDebtBase;
    uint256 _availableBorrowsBase;
    uint256 _currentLiquidationThreshold;
    uint256 _ltv;
    uint256 _healthFactor;

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
    return messenger.sendBorrowMessage(
      destChainSelector,
      facilitator,
      0,
      msg.sender,
      address(this),
      amount,
      liquidator
    );
  }

  function _isUndercollateralized(uint256 totalCollateralBase, uint256 ltv) internal view returns (bool) {
    return (totalCollateralBase * 10000) < (totalDebtBase * ltv);
  }
}
