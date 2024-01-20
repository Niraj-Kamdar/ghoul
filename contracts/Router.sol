// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vault.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IVault.sol";
import "./Messenger.sol";
import "./lib/Encoder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Router is IRouter, Ownable, ERC721 {

    // user -> vaultAddress -> vault
    mapping(address => mapping(address => IVault)) public userVaults;

    public address pool;
    public address facilitator;
    public address liquidator;
    public Messenger messenger;

    constructor(address _pool, address _facilitator, address _liquidator, address _router, address _link) {
      pool = _pool;
      facilitator = _facilitator;
      liquidator = _liquidator;
      messenger = new Messenger(address(this), msg.sender, _router, _link);
    }

    function updateGhoulFacilitator(address _facilitator) onlyOwner public {
      facilitator = _facilitator;
    }

    function createVault() public {
        require(address(userVaults[msg.sender]) == address(0), "Vault already exists");
        Vault newVault = new Vault(pool, messenger, facilitator, liquidator);
        newVault.transferOwnership(msg.sender);
        userVaults[msg.sender].push(newVault);
        emit VaultCreated(msg.sender, address(newVault));
    }

    function getVault(uint256 index) public view returns (IVault) {
        return userVaults[msg.sender][index];
    }

    function borrow(uint256 vaultId, uint256 amount) public returns (bytes32 messageId) {
      IVault memory vault = userVaults[msg.sender];
      require(vault.address != address(0), "Vault not created!");
      return vault.borrow(amount);
    }
}
