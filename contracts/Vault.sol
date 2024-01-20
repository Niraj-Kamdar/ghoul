// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IRouter.sol";
import "./Messenger.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vault is IVault, Ownable {
  IRouter public router;
  IPool public pool;
  Messenger public messenger;
  address public facilitator;
  address public liquidator;

  uint256 public totalDebtBase = 0; // 8 decimal total borrowed gho

  constructor(address _router, address _pool, Messenger _messenger, address _facilitator, address _liquidator) {
    router = IRouter(_router);
    pool = IPool(_pool);
    messenger = _messenger;
    facilitator = _facilitator;
    liquidator = _liquidator;
  }

  function withdraw(address payable recipient, address token, uint256 amount) onlyOwner public {
    if (token == address(0)) {
      require(address(this).balance >= amount, "Insufficient balance");
      recipient.transfer(amount);
    } else {
      IERC20 erc20 = IERC20(token);
      require(erc20.balanceOf(address(this)) >= amount, "Insufficient balance");
      erc20.transfer(recipient, amount);
    }
    emit Withdrawn(token, amount);
  }

  function borrow(address borrower, uint256 amount, uint64 destChainSelector) onlyOwner public returns (bytes32 messageId) {
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
    ) = pool.getUserAccountData(borrower);

    // Update the total Debt
    totalDebtBase += (amount / 10 ** 10);
    // Check if position under collateralized after update
    require(_isUndercollateralized(_totalCollateralBase, _ltv) == false, "UnderCollateralized: Borrow cancelled");

    // Send CCIP mint GHO message
    return messenger.sendBorrowMessage(
      destChainSelector,
      facilitator,
      0,
      borrower,
      address(this),
      amount,
      liquidator
    );
  }

  function _isUndercollateralized(uint256 totalCollateralBase, uint256 ltv) internal view returns (bool) {
    return (totalCollateralBase * 10000) < (totalDebtBase * ltv);
  }
}
