const { networks } = require("../networks")

task("lend-vault", "create vault and send aToken")
  .addParam("router", "address of Router")
  .addParam("aToken", "address of aToken")
  .addParam("amount", "amount of aToken to send")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }

    if (network.name !== "sepolia") {
      throw Error("This task is intended to be executed on the Sepolia network.")
    }

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


    // Fund with aToken
    console.log(`\nSending ${amount} ${aToken} to ${vault} `)
    const aTokenTokenContract = await ethers.getContractAt("@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20", aToken)

    const aTokenTx = await aTokenTokenContract.transfer(router, ethers.utils.parseUnits(aToken_AMOUNT))
    await aTokenTx.wait(1)

    const juelsBalance = await aTokenTokenContract.balanceOf(router)
    const aTokenBalance = ethers.utils.formatEther(juelsBalance.toString())
    console.log(`\nFunded ${router} with ${aTokenBalance} aToken`)
  }
)
