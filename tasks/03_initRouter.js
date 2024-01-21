const { networks } = require("../networks")

task("init-router", "Update Router Facilitator address")
  .addParam("router", "address of Router")
  .addParam("facilitator", "address of facilitator")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }

    if (network.name !== "sepolia") {
      throw Error("This task is intended to be executed on the Sepolia network.")
    }

    const {router, facilitator} = taskArgs;

    // create new Vault
    console.log(`\nUpdate Facilitator address`)
    const routerContract = await ethers.getContractAt("Router", router)

    const tx = await routerContract.updateGhoulFacilitator(facilitator)
    await tx.wait(1)
  
    console.log("Facilitator address updated successfully!")
  }
)
