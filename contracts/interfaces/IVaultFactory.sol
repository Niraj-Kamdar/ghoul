// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IVault.sol";


interface IVaultFactory {

    event VaultCreated(address indexed user, address vault);

    function createVault() external;

    function getVault() external view returns (IVault);
}
