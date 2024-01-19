// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vault.sol";
import "./interfaces/IVaultFactory.sol";
import "./interfaces/IVault.sol";
import "./Messenger.sol";

contract VaultFactory is IVaultFactory {
    mapping(address => Vault) public userVaults;
    address pool;
    Messanger messenger; 

    constructor(address _pool) {
      pool = _pool;
      messanger = new Messanger();
    }

    function createVault() public {
        require(address(userVaults[msg.sender]) == address(0), "Vault already exists");
        Vault newVault = new Vault(msg.sender, pool);
        userVaults[msg.sender] = newVault;
        emit VaultCreated(msg.sender, address(newVault));
    }

    function getVault() public view returns (IVault) {
        return userVaults[msg.sender];
    }
}
