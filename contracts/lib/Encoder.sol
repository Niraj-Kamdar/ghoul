// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Encoder {
    // Operation types represented as uint8
    uint8 constant BORROW = 0;
    uint8 constant REPAY = 1;
    uint8 constant LIQUIDATE = 2;

    // Unified Encode Function
    function encode(uint8 operationType, address borrower, address vault, uint256 amount, address liquidator) public pure returns (string memory) {
        require(operationType >= BORROW && operationType <= LIQUIDATE, "Invalid Operation");

        // For Liquidate, amount is not used, so it's set to 0
        if (operationType == LIQUIDATE) {
            amount = 0;
        }

        // For Borrow and Repay, liquidator is not used, so it's set to address(0)
        if (operationType == BORROW || operationType == REPAY) {
            liquidator = address(0);
        }

        return string(abi.encode(operationType, borrower, vault, amount, liquidator));
    }

    function decode(bytes memory data) public pure returns (uint8 operationType, address borrower, address vault, uint256 amount, address liquidator) {
        (operationType, borrower, vault, amount, liquidator) = abi.decode(data, (uint8, address, address, uint256, address));
        return (operationType, borrower, vault, amount, liquidator);
    }
}
