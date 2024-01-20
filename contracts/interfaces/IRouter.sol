import "./IVault.sol";

interface IRouter {
    event VaultCreated(address indexed user, address vault);

    function createVault() external;

    function getVault(uint256 vaultId) external view returns (IVault);
}