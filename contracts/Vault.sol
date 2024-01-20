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

  uint256 public totalDebtBase = 0; // 8 decimal total borrowed gho

  constructor(address _router) {
    router = IRouter(_router);
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

  function getTotalDebtBase() external view returns (uint256) {
    return totalDebtBase;
  }
}
