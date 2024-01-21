const { networks } = require("../networks")

task("transfer-vault", "transfer vault")
  .addParam("router", "address of Router")
  .addParam("vault", "address of Vault")
  .addParam("receiver", "address of Receiver")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }

    if (network.name !== "sepolia") {
      throw Error("This task is intended to be executed on the Sepolia network.")
    }

    const {vault, receiver, router} = taskArgs;

    const routerContract = await ethers.getContractAt("IERC721", router)

    function addressToUint256(address) {
        // Remove the '0x' prefix and convert the address to a Buffer
        const addressBuffer = Buffer.from(address.slice(2), 'hex');

        // Pad the buffer to 32 bytes
        const paddedBuffer = Buffer.concat([Buffer.alloc(32 - addressBuffer.length), addressBuffer]);

        // Convert the padded buffer to a BigNumber
        return ethers.BigNumber.from(paddedBuffer);
    }

    // Example usage
    const vaultId = addressToUint256(vault);
    console.log(`Vault ID for vault ${vault} is ${vaultId.toString()}`);
    const [deployer] = await ethers.getSigners()

    console.log(`Transferring vault ${vaultId} to ${receiver}`)
    const tx = await routerContract['safeTransferFrom(address,address,uint256)'](deployer.address, receiver, vaultId)
    const receipt = await tx.wait(1)

    const events = receipt.events;

    // Assuming the Transfer event is emitted with tokenId
    let tokenId;
    for (let event of events) {
        if (event.event === "Transfer") {
            // The tokenId is usually the third argument in the Transfer event for ERC721
            tokenId = event.args[2].toString();
            tokenRcvr = event.args[1].toString();
            break;
        }
    }

    console.log(`Vault ${tokenId} transferred to ${tokenRcvr} successfully`)

  }
)
