const { networks } = require("../networks")

task("vault-data", "get vault data")
  .addParam("vault", "address of vault")
  .addParam("router", "address of router")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }

    if (network.name !== "sepolia") {
      throw Error("This task is intended to be executed on the Sepolia network.")
    }

    const {vault, router} = taskArgs;

    console.log(`\nGetting Vault data`)
    const routerContract = await ethers.getContractAt("Router", router)

    const vaultData = await routerContract.getVaultData(vault)

    console.log(vaultData)
})
