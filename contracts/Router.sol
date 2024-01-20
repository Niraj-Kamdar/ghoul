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

    // user -> vault token id -> vault
    mapping(address => mapping(uint256 => IVault)) public userVaults;

    uint256 public nextVaultId = 1;

    address public pool;
    address public facilitator;
    address public liquidator;
    Messenger public messenger;

    constructor(address _pool, address _facilitator, address _liquidator, address _router, address _link) ERC721("GhoulRouter", "GHOUL") {
      pool = _pool;
      facilitator = _facilitator;
      liquidator = _liquidator;
      messenger = new Messenger(address(this), msg.sender, _router, _link);
    }

    function updateGhoulFacilitator(address _facilitator) onlyOwner public {
      facilitator = _facilitator;
    }

    function updateGhoulLiquidator(address _liquidator) onlyOwner public {
      liquidator = _liquidator;
    }

    function updateGhoulPool(address _pool) onlyOwner public {
      pool = _pool;
    }

    function createVault() public {
        Vault newVault = new Vault(address(this), pool, messenger, facilitator, liquidator);
        uint256 vaultId = nextVaultId;
        nextVaultId++;
        require(address(userVaults[msg.sender][vaultId]) == address(0), "Vault already exists");
        userVaults[msg.sender][vaultId] = newVault;
        _safeMint(msg.sender, vaultId);
        emit VaultCreated(msg.sender, vaultId, address(newVault));
    }

    function getVault(uint256 vaultId) public view returns (IVault) {
        return userVaults[msg.sender][vaultId];
    }

    function borrow(uint256 vaultId, uint256 amount, uint64 destChainSelector) public returns (bytes32 messageId) {
      IVault vault = userVaults[msg.sender][vaultId];
      require(address(vault) != address(0), "Vault not created!");
      return vault.borrow(msg.sender, amount, destChainSelector);
    }

    function withdraw(uint256 vaultId, address token, uint256 amount) public {
        IVault vault = userVaults[msg.sender][vaultId];
        require(address(vault) != address(0), "Vault not created!");
        vault.withdraw(payable(msg.sender), token, amount);
    }

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
