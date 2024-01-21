const { networks } = require("../networks")

task("withdraw-vault", "withdraw vault")
  .addParam("router", "address of router")
  .addParam("vault", "address of vault")
  .addParam("token", "address of token to withdraw")
  .addParam("amount", "amount to withdraw")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
    }

    if (network.name !== "sepolia") {
      throw Error("This task is intended to be executed on the Sepolia network.")
    }

    const {vault, token, router, amount} = taskArgs;

    console.log(`\nWithdrawing from Vault`)

    const aTokenTokenContract = await ethers.getContractAt("@aave/aave-token/contracts/open-zeppelin/ERC20.sol:ERC20", token)

    const decimals = await aTokenTokenContract.decimals()
    const parsedAmount = ethers.utils.parseUnits(amount, decimals);

    const routerContract = await ethers.getContractAt("Router", router)

    const withdrawTx = await routerContract['withdraw(address,address,uint256)'](vault, token, parsedAmount);

    await withdrawTx.wait(1)
})
