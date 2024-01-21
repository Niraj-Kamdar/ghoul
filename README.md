# Ghoul Finance
Ghoul Finance: Revolutionizing DeFi with Cross-Chain Ledning-Borrowing and NFT-based Vaults.

### Description
Ghoul Finance is an innovative DeFi protocol that leverages the idle liquidity across blockchains to create a dynamic borrowing and lending ecosystem. At its core, Ghoul Finance introduces a unique concept where each Vault, representing a user's portfolio of collateral and debt, is an NFT. This NFT-based approach enables the seamless transfer of financial positions between users. The protocol primarily operates across two chains - Sepolia and Fuji, utilizing Chainlink's CCIP for secure cross-chain communication. Borrowers can access liquidity by minting GHO tokens on Fuji, backed by assets in the AAVE pool on Sepolia. Additionally, Ghoul Finance incorporates mechanisms for repayment and liquidation, ensuring a balanced and secure financial environment.

### How It Works
[![](https://mermaid.ink/img/pako:eNqNVMtu2zAQ_JUFe3GA5Ad0CNCmcFOgLyRGT7psqJW9NUUqJJUgDfLvXZqKKVs2UF9MrWZmZ3YJvSrtGlKVCvQ4kNX0mXHtsastyA91dB6-kW3IH1T4ceAG5ZirPfrImnu0Ee7cEMkDhvG0uKfeGcaLOXSJmg3HpJPwk8fFcvjDwsicD3DjCSPBbxxMzLVs6ur6OnepRkgABEvPU2QGXAk0cyr4zjaGAoMfy1VpZQTEdn2my8qjDW3Kh08E0W3JwgJX6f9CHiFuCJ5y73fBB-e9ez4v-dVy5J31PRK-3P7M4gcRCucX-db5LoAkIW_RgN6Q3oYj-GSiFdylDQcJLjY74ZUmqZJtgbPQCIgtRpaz3iCPHiZa81kWqdMCR9EPfJX8nnp86UisuXYaf9r6iPxp8DYTuSkuwine_qKgMXkI6Lel597k_m7POGZ8RTJ20Bgo-RxSJu2MkbpHw393wc_s7Wa3JeAWyPCaHwyB7HEvPCee3uAED713msLJxCVKBR-1pv5gU5Pk_zGskj1d8d4Fnrk96vh-lsVOKepSdeQ72Zd8dV6TQK3kfUe1quTYyFJqVds3weEQ3f2L1aqKfqBLNfRJbvxCqapFE-jtH1RIqRg?type=png)](https://mermaid.live/edit#pako:eNqNVMtu2zAQ_JUFe3GA5Ad0CNCmcFOgLyRGT7psqJW9NUUqJJUgDfLvXZqKKVs2UF9MrWZmZ3YJvSrtGlKVCvQ4kNX0mXHtsastyA91dB6-kW3IH1T4ceAG5ZirPfrImnu0Ee7cEMkDhvG0uKfeGcaLOXSJmg3HpJPwk8fFcvjDwsicD3DjCSPBbxxMzLVs6ur6OnepRkgABEvPU2QGXAk0cyr4zjaGAoMfy1VpZQTEdn2my8qjDW3Kh08E0W3JwgJX6f9CHiFuCJ5y73fBB-e9ez4v-dVy5J31PRK-3P7M4gcRCucX-db5LoAkIW_RgN6Q3oYj-GSiFdylDQcJLjY74ZUmqZJtgbPQCIgtRpaz3iCPHiZa81kWqdMCR9EPfJX8nnp86UisuXYaf9r6iPxp8DYTuSkuwine_qKgMXkI6Lel597k_m7POGZ8RTJ20Bgo-RxSJu2MkbpHw393wc_s7Wa3JeAWyPCaHwyB7HEvPCee3uAED713msLJxCVKBR-1pv5gU5Pk_zGskj1d8d4Fnrk96vh-lsVOKepSdeQ72Zd8dV6TQK3kfUe1quTYyFJqVds3weEQ3f2L1aqKfqBLNfRJbvxCqapFE-jtH1RIqRg)

1. **Vault Creation**: Users create a new Vault on the Router (Sepolia), which then mints a corresponding Vault NFT.

2. **Lending**: Lenders transfer AAVE tokens (aTokens) to their Vault, establishing the collateral.

3. **Borrowing**:
   - The lender initiates a borrowing request for GHO tokens.
   - The Router performs internal checks before requesting the Facilitator (Fuji) to mint GHO tokens.
   - The Facilitator mints GHO tokens directly to the lender on the destination chain.

4. **Repayment**:
   - The lender initiates repayment on the Facilitator.
   - The Facilitator burns the repaid GHO tokens and notifies the Router to mark the repayment.

5. **Liquidation (Not Implemented)**:
   - In cases of undercollateralization, a Liquidator can initiate the liquidation process.
   - The Router verifies eligibility for liquidation and requests the Facilitator to proceed.
   - The Facilitator accepts GHO token repayments and instructs the Router to liquidate the position.
   - The Router completes the liquidation process, affecting the corresponding NFT Vault by transferring the ownership of vault to the liquidator

## Core Technologies
- **Chainlink CCIP**: Enables secure cross-chain communication between Sepolia and Fuji.
- **AAVE Pool on Sepolia**: Acts as the source of collateralized assets.
- **GHO Token on Fuji**: The stablecoin used within the Ghoul Finance ecosystem.
- **Hardhat**: Utilized for developing and demonstrating the protocol.

## Setup - Prerequisites

Please go through this section and complete the steps before you proceed with the rest of this README.

This project uses [Hardhat tasks](https://hardhat.org/hardhat-runner/docs/guides/tasks-and-scripts). Each task file is named with a sequential number prefix that is the order of steps to use this use case's code.

Clone the project and run `npm install` in the repo's root directory.

You need to fund your developer wallet EOA on the source chain as well as on the destination chain.

On the source chain Fuji (where `Router.sol` is deployed you need):

- LINK tokens (learn how to get them for each chain [here](https://docs.chain.link/resources/link-token-contracts))
- a little Fuji AVAX (go [here](https://faucets.chain.link/fuji))
- a little AAVE aToken (go [here](https://gho.aave.com/faucet/))

On the destination chain chain Sepolia (where `Facilitator.sol` is deployed you need):

- LINK tokens (use the same URL from before but switch networks and make sure you're interacting with the right LINK token contract)
- A little Sepolia Eth (go [here](https://faucets.chain.link/sepolia))

### Configuration

This repo has been written to make it easy for you to quickly run through its steps. It has favoured ease of use over flexibility, and so it assumes you will follow it without modification. This means the configuration is already done for you in the code. You just need to supply the environment variables in the next step and make sure your wallet is funded with the right tokens on each of the chains.

You can inspect the configuration details in the `./networks.js` file. This file exports config data that are used by the tasks in `./tasks`.

### Environment Variables.
Copy the .env.sample file and fill it with your private key and RPC URLs of Fuji and Sepolia testnets.

## Step-by-Step Process

### 1. Deploy and Initialize Contracts
- **Deploy Router on Sepolia**: 
  - Command: `npx hardhat setup-router --network sepolia`
  - This deploys the Router contract on Sepolia. Note the contract address upon deployment.
  
- **Deploy Facilitator on Fuji**: 
  - Command: `npx hardhat setup-facilitator --network fuji`
  - Deploys the Facilitator contract on Fuji. Record the contract address.

- **Initialize Router with Facilitator Address**: 
  - Command: `npx hardhat init-router --router [Router Address] --facilitator [Facilitator Address] --network sepolia`
  - Links the Router with the Facilitator.

- **Initialize Facilitator**: 
  - Command: `npx hardhat init-facilitator --router [Router Address] --facilitator [Facilitator Address] --network fuji`
  - Links the Facilitator with the Router.

### 2. Creating a Vault
- **Create a New Vault**: 
  - Command: `npx hardhat create-vault --router [Router Address] --network sepolia`
  - Creates a new Vault (NFT) and records its address.

### 3. Lending Process
- **Lend to the Vault**: 
  - Command: `npx hardhat lend-vault --vault [Vault Address] --aToken [aToken Address] --amount [Amount to Lend] --network sepolia`
  - Lends a specified amount of aTokens to the Vault.

### 4. Borrowing GHO Tokens
- **Borrow GHO Tokens**: 
  - Command: `npx hardhat borrow-gho --router [Router Address] --vault [Vault Address] --amount [Amount of GHO to Borrow] --network sepolia`
  - Initiates the borrowing of GHO tokens against the Vault's collateral.

### 5. Repaying the Loan
- **Repay GHO Loan**: 
  - Command: `npx hardhat repay --vault [Vault Address] --facilitator [Facilitator Address] --amount [Repayment Amount] --network fuji`
  - Repays the borrowed GHO tokens. The Facilitator will burn the repaid tokens.

### 6. Managing the Vault
- **Withdraw Assets from the Vault**: 
  - Command: `npx hardhat withdraw-vault --router [Router Address] --vault [Vault Address] --token [Token Address] --amount [Amount to Withdraw] --network sepolia`
  - Withdraws specified assets from the Vault.

- **Transfer the Vault (NFT)**: 
  - Command: `npx hardhat transfer-vault --router [Router Address] --vault [Vault Address] --receiver [Receiver Address] --network sepolia`
  - Transfers the Vault (NFT) to another user.

- **View Vault Data**: 
  - Command: `npx hardhat vault-data --vault [Vault Address] --router [Router Address] --network sepolia`
  - Retrieves and displays data associated with a specific Vault.

### Note:
- Replace `[Router Address]`, `[Facilitator Address]`, `[Vault Address]`, `[aToken Address]`, `[Token Address]`, and `[Receiver Address]` with the respective contract addresses and wallet addresses.
- Replace `[Amount to Lend]`, `[Amount of GHO to Borrow]`, `[Repayment Amount]`, and `[Amount to Withdraw]` with the desired numeric values.

## Conclusion
This detailed process allows users to engage with Ghoul Finance's lending and borrowing protocol effectively. By following these steps and executing the corresponding Hardhat commands, users can create and manage Vaults, borrow GHO tokens, and ensure their financial activities align with their strategies in the DeFi space.