// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IVault {
  event Withdrawn(address indexed withdrawer, address indexed token, uint256 amount);

  function withdraw(address payable recipient, address token, uint256 amount) external;
}
