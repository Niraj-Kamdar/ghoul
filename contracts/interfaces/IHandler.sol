// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHandler {
  function borrow(
    address borrower, 
    address vault, 
    uint256 amount
  ) external;

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