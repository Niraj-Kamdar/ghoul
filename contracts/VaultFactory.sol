// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vault.sol";
import "./interfaces/IVaultFactory.sol";
import "./interfaces/IVault.sol";
import "./Messenger.sol";
import "./lib/Encoder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultFactory is IVaultFactory, Ownable {
    mapping(address => Vault) public userVaults;
    address pool;
    Messenger messenger;
    address facilitator;

    constructor(address _pool, address _link) {
      pool = _pool;
      // TODO: set messenger constructor params
      messenger = new Messenger(address(0), msg.sender, address(0), _link);
    }

    function updateGhoulFacilitator(address _facilitator) onlyOwner public {
      facilitator = _facilitator;
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

//    function sendBorrowMessage(uint64 destinationChainSelector, address staker, address token, uint256 amount) public returns (bytes32 messageId) {
//      require(facilitator != address(0), "facilitator not defined!");
//
//      string memory data = Encoder.encode(staker, token, amount);
//      bytes32 messageId = messenger.sendMessagePayLINK(destinationChainSelector, facilitator, data);
//      require(messageId != bytes32(0), "Message not sent!");
//
//      return messageId;
//    }
}
