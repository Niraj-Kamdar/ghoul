// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 * THIS CONTRACT REMOVED ALL ACCESS CONTROL FOR TESTING PURPOSES
 */

/// @title - A simple messenger contract for sending/receving string data across chains.
interface IMessenger {
    // Custom errors to provide more descriptive revert messages.
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
    error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
    error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        uint8 operationType, 
        address borrower, 
        address vault, 
        uint256 amount, 
        address liquidator,
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the CCIP message.
    );

    // Event emitted when a message is received from another chain.
    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender contract from the source chain.
        uint8 operationType, 
        address borrower, 
        address vault, 
        uint256 amount, 
        address liquidator
    );

    function sendMessagePayLINK(
        uint64 _destinationChainSelector,
        address _receiver,
        uint8 _operationType, 
        address _borrower, 
        address _vault, 
        uint256 _amount, 
        address _liquidator
    ) external returns (bytes32 messageId);
}
