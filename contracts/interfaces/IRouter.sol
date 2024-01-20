import "./IVault.sol";

interface IRouter {
    event VaultCreated(address indexed user, address vault);

    function createVault() external;

    function getVault(address vault) external view returns (IVault);
}