// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IGhoToken} from "./lib/gho-core/src/contracts/gho/interfaces/IGhoToken.sol";
import {Messenger} from "./Messenger.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 * THIS CONTRACT REMOVED ALL ACCESS CONTROL FOR TESTING PURPOSES
 */

contract Facilitator is Messenger {
    IGhoToken private s_ghoToken;
    uint64 public destinationChainSelector;
    address public ghoulRouter;

    mapping (bytes32 => bytes) public messages;

    constructor(uint64 _destinationChainSelector, address _router, address _link, address _gho) Messenger(_router, _link) {
        s_ghoToken = IGhoToken(_gho);
        destinationChainSelector = _destinationChainSelector;
    }

    function updateGhoulRouter(address _router) onlyOwner public {
        ghoulRouter = _router;
    }

    function _borrow(address _borrower, uint256 _amount) internal {
        s_ghoToken.mint(_borrower, _amount);
    }

    function repay(address _borrower, address _vault, uint256 _amount) external {
        s_ghoToken.transferFrom(_borrower, address(0), _amount);  // Burn tokens
        
        sendMessagePayLINK(destinationChainSelector, ghoulRouter, REPAY, _borrower, _vault, _amount, address(0));
    }

    // function _liquidateInit(address _borrower, address _vault, uint256 _amount, address _liquidator) internal {
    //     s_ghoToken.transferFrom(_borrower, address(0), _amount);  // Burn tokens
        
    //     // send liquidation ack
    //     sendMessagePayLINK(destinationChainSelector, ghoulRouter, LIQUIDATE, _borrower, _vault, _amount, _liquidator);
    // }

    // function _liquidateOk()

    // function _liquidateFail()

    /// handle a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    )
        internal
        override
    {
        messages[any2EvmMessage.messageId] = any2EvmMessage.data;

        uint8 operationType;
        address borrower;
        address vault;
        uint256 amount;
        address liquidator;

        (operationType, borrower, vault, amount, liquidator) = abi.decode(any2EvmMessage.data, (uint8, address, address, uint256, address));

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            operationType,
            borrower,
            vault,
            amount,
            liquidator
        );

        if (operationType == BORROW) {
            _borrow(borrower, amount);
        }
    }
}
