// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IVault {
  event Deposited(uint256 amount);
  event Withdrawn(address token, uint256 amount);

  function withdraw(address token, uint256 amount) external;

  function approveBorrow(uint256 amount) external;
}
