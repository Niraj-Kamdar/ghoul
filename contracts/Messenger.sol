// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 * THIS CONTRACT REMOVED ALL ACCESS CONTROL FOR TESTING PURPOSES
 */

/// @title - A simple messenger contract for sending/receving string data across chains.
abstract contract Messenger is CCIPReceiver, OwnerIsCreator {
    uint8 constant public BORROW = 0;
    uint8 constant public REPAY = 1;
    uint8 constant public LIQUIDATE = 2;

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

    // bytes32 private s_lastReceivedMessageId; // Store the last received messageId.
    // bytes private s_lastReceivedText; // Store the last received text.


    IERC20 private s_linkToken;

    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    constructor(address _router, address _link) CCIPReceiver(_router) {
        s_linkToken = IERC20(_link);
    }

    function sendMessagePayLINK(
        uint64 _destinationChainSelector,
        address _receiver,
        uint8 _operationType, 
        address _borrower, 
        address _vault, 
        uint256 _amount, 
        address _liquidator
    )
        internal
        returns (bytes32 messageId)
    {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            address(s_linkToken),
            _operationType, 
            _borrower, 
            _vault, 
            _amount, 
            _liquidator
        );

        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(this.getRouter());

        // Get the fee required to send the CCIP message
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        s_linkToken.approve(address(router), fees);

        // Send the CCIP message through the router and store the returned CCIP message ID
        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        // Emit an event with message details
        emit MessageSent(
            messageId,
            _destinationChainSelector,
            _receiver,
            _operationType, 
            _borrower, 
            _vault, 
            _amount, 
            _liquidator,
            address(s_linkToken),
            fees
        );

        // Return the CCIP message ID
        return messageId;
    }

    // /// handle a received message
    // function _ccipReceive(
    //     Client.Any2EVMMessage memory any2EvmMessage
    // )
    //     internal
    //     override
    // {
    //     s_lastReceivedMessageId = any2EvmMessage.messageId; // fetch the messageId
    //     s_lastReceivedText = any2EvmMessage.data;

    //     uint8 operationType;
    //     address borrower;
    //     address vault;
    //     uint256 amount;
    //     address liquidator;

    //     (operationType, borrower, vault, amount, liquidator) = abi.decode(any2EvmMessage.data, (uint8, address, address, uint256, address));

    //     emit MessageReceived(
    //         any2EvmMessage.messageId,
    //         any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
    //         abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
    //         operationType,
    //         borrower,
    //         vault,
    //         amount,
    //         liquidator
    //     );

    // }

    function _buildCCIPMessage(
        address _receiver,
        address _feeTokenAddress,
        uint8 _operationType, 
        address _borrower, 
        address _vault, 
        uint256 _amount, 
        address _liquidator
    ) internal pure returns (Client.EVM2AnyMessage memory) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message

        bytes memory data = abi.encode(_operationType, _borrower, _vault, _amount, _liquidator);

        return
            Client.EVM2AnyMessage({
                receiver: abi.encode(_receiver), // ABI-encoded receiver address
                data: data, // ABI-encoded string
                tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array aas no tokens are transferred
                extraArgs: Client._argsToBytes(
                    // Additional arguments, setting gas limit
                    Client.EVMExtraArgsV1({gasLimit: 200_000, strict: true})
                ),
                // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
                feeToken: _feeTokenAddress
            });
    }

    // function getLastReceivedMessageDetails()
    //     external
    //     view
    //     returns (bytes32 messageId, bytes memory text)
    // {
    //     return (s_lastReceivedMessageId, s_lastReceivedText);
    // }

    /// @notice Fallback function to allow the contract to receive Ether.
    /// @dev This function has no function body, making it a default function for receiving Ether.
    /// It is automatically called when Ether is sent to the contract without any data.
    receive() external payable {}

    /// @notice Allows the contract owner to withdraw the entire balance of Ether from the contract.
    /// @dev This function reverts if there are no funds to withdraw or if the transfer fails.
    /// It should only be callable by the owner of the contract.
    /// @param _beneficiary The address to which the Ether should be sent.
    function withdraw(address _beneficiary) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = address(this).balance;

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        // Attempt to send the funds, capturing the success status and discarding any return data
        (bool sent, ) = _beneficiary.call{value: amount}("");

        // Revert if the send failed, with information about the attempted transfer
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    /// @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token.
    /// @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
    /// @param _beneficiary The address to which the tokens will be sent.
    /// @param _token The contract address of the ERC20 token to be withdrawn.
    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        IERC20(_token).transfer(_beneficiary, amount);
    }
}
