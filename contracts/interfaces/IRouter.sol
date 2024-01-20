import "./IVault.sol";

interface IRouter {
    event VaultCreated(address indexed user, uint256 vaultId, address vault);

    function createVault() external;

    function getVault(uint256 vaultId) external view returns (IVault);

    // function listVaults() 

    // function lend()
    // function borrow()
    // function liquidate()
    // function _ccip_repay()
    // Router can be ERC721
    // Vault can be NFT
    // 

}