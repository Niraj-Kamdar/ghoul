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

    function borrow(uint256 vaultId, uint256 amount) public returns (bytes32 messageId) {
      IVault vault = userVaults[msg.sender][vaultId];
      require(address(vault) != address(0), "Vault not created!");
      return vault.borrow(msg.sender, amount);
    }

    function withdraw(uint256 vaultId, address token, uint256 amount) public {
        IVault vault = userVaults[msg.sender][vaultId];
        require(address(vault) != address(0), "Vault not created!");
        vault.withdraw(payable(msg.sender), token, amount);
    }


//    function _safeMint(address to, uint256 tokenId) internal {
//        _safeMint(to, tokenId, "");
//    }
//
//    function _safeMint(address to, uint256 tokenId, bytes memory data) internal {
//        _mint(to, tokenId);
//        require(
//            _checkOnERC721Received(address(0), to, tokenId, data),
//            "ERC721: transfer to non ERC721Receiver implementer"
//        );
//    }
//
//    function _mint(address to, uint256 tokenId) internal {
//        require(to != address(0), "ERC721: mint to the zero address");
//        require(!_exists(tokenId), "ERC721: token already minted");
//
//        _beforeTokenTransfer(address(0), to, tokenId, 1);
//
//        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
//        require(!_exists(tokenId), "ERC721: token already minted");
//
//        unchecked {
//        // Will not overflow unless all 2**256 token ids are minted to the same owner.
//        // Given that tokens are minted one by one, it is impossible in practice that
//        // this ever happens. Might change if we allow batch minting.
//        // The ERC fails to describe this case.
//            _balances[to] += 1;
//        }
//
//        _owners[tokenId] = to;
//
//        emit Transfer(address(0), to, tokenId);
//
//        _afterTokenTransfer(address(0), to, tokenId, 1);
//    }
}
