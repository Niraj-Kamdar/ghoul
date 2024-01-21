const { networks } = require("../networks")

task("repay", "Repay GHO loan")
  .addParam("vault", "address of Vault")
  .addParam("facilitator", "address of facilitator")
  .addParam("amount", "Amount to repay")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }
    if (network.name !== "fuji") {
      throw Error("This task is intended to be executed on the Fuji network.")
    }

    const {vault, facilitator, amount} = taskArgs;

    const [deployer] = await ethers.getSigners()
    const parsedAmount = ethers.utils.parseUnits(amount)

    const facilitatorContract = await ethers.getContractAt("Facilitator", facilitator)

    const router = await facilitatorContract.ghoulRouter()
    const destinationChainSelector = await facilitatorContract.destinationChainSelector()

    console.log(`\nApproving ${amount} GHO for ${facilitator}`)
    const ghoAddress = networks.fuji.ghoToken
    const ghoTokenContract = await ethers.getContractAt("@aave/aave-token/contracts/open-zeppelin/ERC20.sol:ERC20", ghoAddress)

    const approveTx = await ghoTokenContract.approve(facilitator, parsedAmount)
    await approveTx.wait(1)

    const juelsBalance = await ghoTokenContract.allowance(deployer.address, facilitator)
    const ghoAllowance = ethers.utils.formatEther(juelsBalance.toString())
    console.log(`\nAllowed ${facilitator} to use ${ghoAllowance} GHO`)

    console.log(`Router is recorded at: ${router}`)
    console.log(`destinationChainSelector at: ${destinationChainSelector}`)

    console.log(`\nRepay ${amount} GHO to ${vault}`)
    const tx = await facilitatorContract.repay(deployer.address, vault, parsedAmount)
    const receipt = await tx.wait(1);
    console.log("Debt repaid successfully!")

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

    console.log(`Message ${messageId} sent to repay GHO`)
  }
)
