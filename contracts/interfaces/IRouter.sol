interface IRouter {
    event VaultCreated(address indexed user, address vault);

    function createVault() external;

    function getVault() external view returns (IVault);

    // function listVaults() 

    // function lend()
    // function borrow()
    // function liquidate()
    // function _ccip_repay()
    // Router can be ERC721
    // Vault can be NFT
    // 

}