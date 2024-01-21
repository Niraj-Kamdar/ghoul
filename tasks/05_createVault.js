const { networks } = require("../networks")

task("create-vault", "create vault")
  .addParam("router", "address of Router")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }

    if (network.name !== "sepolia") {
      throw Error("This task is intended to be executed on the Sepolia network.")
    }

    const {router} = taskArgs;

    // create new Vault
    console.log(`\nCreating new Vault`)
    const routerContract = await ethers.getContractAt("Router", router)
    
    const vaultTx = await routerContract.createVault()
    // Wait for the transaction to be mined
    const receipt = await vaultTx.wait(1);

    // Extract the events from the transaction receipt
    const events = receipt.events;

    // Assuming the Transfer event is emitted with tokenId
    let tokenId;
    for (let event of events) {
        if (event.event === "Transfer") {
            // The tokenId is usually the third argument in the Transfer event for ERC721
            tokenId = event.args[2].toString();
            break;
        }
    }

    console.log("NFT ID:", tokenId);

    // Assuming you have a BigNumber instance `uint256Value` representing the uint256
    const uint256Value = ethers.BigNumber.from(tokenId);

    // Convert the BigNumber to a hex string (remove '0x' prefix if present)
    let hexString = uint256Value.toHexString();

    // Ensure the hex string is 40 characters long (20 bytes), pad with zeros if necessary
    if (hexString.length < 42) {
        hexString = ethers.utils.hexZeroPad(hexString, 20);
    }

    // The resulting string is the Ethereum address
    const address = hexString.toLowerCase(); // Convert to lowercase to get the checksum address

    console.log("Vault Address:", address);

    // Get the code at the specified address
    const code = await ethers.provider.getCode(address);

    // Check if the address is a contract
    if(code !== '0x') {
      console.log("Vault contract created successfully!")
    } else {
      console.error("Vault does not exist!")
    }
  }
)
