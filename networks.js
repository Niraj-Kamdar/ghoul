// All supported networks and related contract addresses are defined here.
//
// LINK token addresses: https://docs.chain.link/resources/link-token-contracts/
// Price feeds addresses: https://docs.chain.link/data-feeds/price-feeds/addresses
// Chain IDs: https://chainlist.org/?testnets=true

require('dotenv').config();

const DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS = 2

const npmCommand = process.env.npm_lifecycle_event
const isTestEnvironment = npmCommand === "test" || npmCommand === "test:unit"

// Set EVM private key (required)
const PRIVATE_KEY = process.env.PRIVATE_KEY

if (!isTestEnvironment && !PRIVATE_KEY) {
  throw Error("Set the PRIVATE_KEY environment variable with your EVM wallet private key")
}

const networks = {
  sepolia: {
    url: process.env.SEPOLIA_RPC_URL || "THIS HAS NOT BEEN SET",
    gasPrice: undefined,
    router: "0x0bf3de8c5d3e8a2b34d2beeb17abfcebaf363a59",
    chainSelector: "16015286601757825753",
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: "THIS HAS NOT BEEN SET",
    chainId: 11155111,
    aavePool: "0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951",
    confirmations: DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS,
    nativeCurrencySymbol: "ETH",
    linkToken: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
    bnmToken: "0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05", // LINK/SEPOLIA-ETH
  },
  fuji: {
    url: process.env.AVALANCHE_FUJI_RPC_URL || "THIS HAS NOT BEEN SET",
    router: "0xF694E193200268f9a4868e4Aa017A0118C9a8177",
    chainSelector: "14767482510784806043",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: "THIS HAS NOT BEEN SET",
    chainId: 43113,
    confirmations: 2 * DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS,
    nativeCurrencySymbol: "AVAX",
    linkToken: "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846",
    bnmToken: "0xd21341536c5cf5eb1bcb58f6723ce26e8d8e90e4",
    ghoToken: "0xc7b331f1E6E548493758e00A715F7B256D710E70"
  },
  mumbai: {
    url: process.env.POLYGON_MUMBAI_RPC_URL || "THIS HAS NOT BEEN SET",
    router: "0x1035CabC275068e0F4b745A29CEDf38E13aF41b1",
    chainSelector: "12532609583862916517",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: "THIS HAS NOT BEEN SET",
    chainId: 80001,
    confirmations: 2 * DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS,
    nativeCurrencySymbol: "MATIC",
    linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
    wMaticToken: "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889",
  },
}

module.exports = {
  networks,
}
