const { networks } = require("../networks")
const fs = require('fs')

task("send-borrow-message", "send a message from Messenger.sol on Fuji")
  .addParam("receiver", "address of endpoint on the destination chain")
  .addParam("destChain", "destination chain as specified in networks.js file")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }

    if (network.name !== "fuji") {
      throw Error("This task is intended to be executed on the Fuji network.")
    }

    // // uint64 destinationChainSelector, address receiver, uint8 operationType, address borrower, address vault, uint256 amount, address liquidator

    let { receiver, destChain } = taskArgs

    const destChainSelector = networks[destChain].chainSelector
    const sender = (await ethers.getSigners())[0].address

      const deploymentsStr = fs.readFileSync(`contractDeployments/deployments_${network.name}.json`, 'utf-8')
      const deployments = JSON.parse(deploymentsStr);

    const messengerFactory = await ethers.getContractFactory("Messenger", {
        libraries: {
            Encoder: deployments.encoder,
        },
    })
    const messengerContract = await messengerFactory.attach(deployments.messenger)

    const [fees, _] = await messengerContract.getNativeBorrowMessageFees(destChainSelector, receiver, 0, sender, sender, 1, sender);

    const sendBorrowMessageTx = await messengerContract.sendBorrowMessage(destChainSelector, receiver, 0, sender, sender, 1, sender, { value: fees })
    await sendBorrowMessageTx.wait()
    console.log("\nTx hash is ", sendBorrowMessageTx.hash)

    console.log(`\nPlease visit the CCIP Explorer at 'https://ccip.chain.link' and paste in the Tx Hash '${sendBorrowMessageTx.hash}' to view the status of your CCIP tx.
    Be sure to make a note of your Message Id for use in the next steps.`)
  })
