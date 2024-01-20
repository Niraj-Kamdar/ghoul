const { networks } = require("../networks")

task("setup-router", "deploy Router.sol").setAction(async (taskArgs, hre) => {
  if (network.name === "hardhat") {
    throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
  }

  if (network.name !== "sepolia") {
    throw Error("This task is intended to be executed on the Sepolia network.")
  }
  
  // const bnmToken = networks[network.name].bnmToken
  // if (!bnmToken) {
  //   throw Error("Missing BNM Token Address")
  // }

  const ROUTER = networks[network.name].router
  const LINK = networks[network.name].linkToken
  const LINK_AMOUNT = "0.5"

  const destinationChainSelector = networks["fuji"].chainSelector
  const aavePool = networks["sepolia"].aavePool

  console.log("\n__Compiling Contracts__")
  await run("compile")

  console.log(`\nDeploying Router.sol to ${network.name}...`)
  const routerFactory = await ethers.getContractFactory("Router")
  const routerContract = await routerFactory.deploy(destinationChainSelector,aavePool, ROUTER, LINK)
  await routerContract.deployTransaction.wait(1)

  console.log(`\nRouter contract is deployed to ${network.name} at ${routerContract.address}`)

  const [deployer] = await ethers.getSigners()
  // const routerContract = {address: "0x4e0F8DE6F290FC5C7571A2DE1dca2B0Ae684ed91"}

  // Fund with LINK
  console.log(`\nFunding ${routerContract.address} with ${LINK_AMOUNT} LINK `)
  const linkTokenContract = await ethers.getContractAt("@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20", networks[network.name].linkToken)

  // Transfer LINK tokens to the contract
  const linkTx = await linkTokenContract.transfer(routerContract.address, ethers.utils.parseEther(LINK_AMOUNT))
  await linkTx.wait(1)

  const juelsBalance = await linkTokenContract.balanceOf(routerContract.address)
  const linkBalance = ethers.utils.formatEther(juelsBalance.toString())
  console.log(`\nFunded ${routerContract.address} with ${linkBalance} LINK`)

  // // Get the MockUSDC Contract address.
  // const usdcToken = await routerContract.usdcToken()
  // console.log(`\nMockUSDC contract is deployed to ${network.name} at ${usdcToken}`)
})
