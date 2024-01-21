const { networks } = require("../networks")

task("init-facilitator", "Initialize Facilitator.sol")
  .addParam("router", "address of Router")
  .addParam("facilitator", "address of facilitator")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }
    if (network.name !== "fuji") {
      throw Error("This task is intended to be executed on the Fuji network.")
    }

    const {router, facilitator} = taskArgs;

    // create new Vault
    console.log(`\nUpdate Facilitator address`)
    const facilitatorContract = await ethers.getContractAt("Facilitator", facilitator)

    const tx = await facilitatorContract.updateGhoulRouter(router)
    await tx.wait(1)
  
    console.log("router address updated successfully!")
  }
)
