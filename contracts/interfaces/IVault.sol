// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IVault {
  event Deposited(uint256 amount);
  event Withdrawn(address token, uint256 amount);

  function withdraw(address payable recipient, address token, uint256 amount) external;

  function borrow(address borrower, uint256 amount, uint64 destChainSelector) external returns (bytes32 messageId);
}
