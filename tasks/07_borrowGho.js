const { networks } = require("../networks")

task("borrow-gho", "create vault")
  .addParam("router", "address of Router")
  .addParam("vault", "address of vault")
  .addParam("amount", "amount of gho to borrow")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }

    if (network.name !== "sepolia") {
      throw Error("This task is intended to be executed on the Sepolia network.")
    }

    const {router, vault, amount} = taskArgs;

    console.log(`\nInitiating borrow`)
    const routerContract = await ethers.getContractAt("Router", router)

    const parsedAmount = ethers.utils.parseUnits(amount)
    const borrowTx = await routerContract.initBorrow(vault, parsedAmount)
    // Wait for the transaction to be mined
    const receipt = await borrowTx.wait(1);

    // Extract the events from the transaction receipt
    const events = receipt.events;

    let messageId;
    for (let event of events) {
        if (event.event === "MessageSent") {
            // The tokenId is usually the third argument in the Transfer event for ERC721
            messageId = event.args[0].toString();
            break;
        }
    }

    console.log(`Message ${messageId} sent to borrow GHO`)
})
