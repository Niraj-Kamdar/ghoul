const { networks } = require("../networks")

task("lend-vault", "create vault and send aToken")
  .addParam("vault", "address of Vault")
  .addParam("aToken", "address of aToken")
  .addParam("amount", "amount of aToken to send")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }

    if (network.name !== "sepolia") {
      throw Error("This task is intended to be executed on the Sepolia network.")
    }

    const {vault, aToken, amount} = taskArgs;
    
    // Fund with aToken
    console.log(`\nSending ${amount} ${aToken} to ${vault} `)
    const aTokenTokenContract = await ethers.getContractAt("@aave/aave-token/contracts/open-zeppelin/ERC20.sol:ERC20", aToken)

    const decimals = await aTokenTokenContract.decimals()
    const parsedAmount = ethers.utils.parseUnits(amount, decimals);

    const aTokenTx = await aTokenTokenContract.transfer(vault, parsedAmount)
    await aTokenTx.wait(1)

    const juelsBalance = await aTokenTokenContract.balanceOf(vault)
    const aTokenBalance = ethers.utils.formatEther(juelsBalance.toString(), decimals)
    console.log(`\nFunded ${vault} with ${aTokenBalance} aToken`)
  }
)
