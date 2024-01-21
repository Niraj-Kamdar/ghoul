const { networks } = require("../networks")

task("setup-facilitator", "deploy Facilitator.sol").setAction(async (taskArgs, hre) => {
  if (network.name === "hardhat") {
    throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
  }
  if (network.name !== "fuji") {
    throw Error("This task is intended to be executed on the Fuji network.")
  }

  const ROUTER = networks[network.name].router
  const LINK = networks[network.name].linkToken

  const destinationChainSelector = networks["sepolia"].chainSelector

  const LINK_AMOUNT = "0.5"

  console.log("\n__Compiling Contracts__")
  await run("compile")

  console.log(`\nDeploying GhoToken.sol to ${network.name}...`)
  const ghoFactory = await ethers.getContractFactory("contracts/lib/gho-core/src/contracts/gho/GhoToken.sol:GhoToken")
  const ghoContract = await ghoFactory.deploy()
  await ghoContract.deployTransaction.wait(1)

  console.log(`\nGhoToken contract is deployed to ${network.name} at ${ghoContract.address}`)

  console.log(`\nDeploying faciliator.sol to ${network.name}...`)
  const faciliatorFactory = await ethers.getContractFactory("Facilitator")
  const faciliatorContract = await faciliatorFactory.deploy(destinationChainSelector, ROUTER, LINK, ghoContract.address)
  await faciliatorContract.deployTransaction.wait(1)

  console.log(`\nfaciliator contract is deployed to ${network.name} at ${faciliatorContract.address}`)

  // add faciliator to GHO
  console.log(`\nAdd facilitator ${faciliatorContract.address} to ${ghoContract.address} `)

  const addFacilitatorTx = await ghoContract.addFacilitator(faciliatorContract.address, {
    bucketCapacity: "340282366920938463463374607431768211455",
    bucketLevel: 0,
    label: "Ghoul Fuji Facilitator"
  })
  await addFacilitatorTx.wait(1)

  console.log(`\nFacilitator added ${faciliatorContract.address}`)

  const [deployer] = await ethers.getSigners()
  // add owner faciliator to GHO for testing
  console.log(`\nAdd facilitator ${deployer.address} to ${ghoContract.address} `)

  const addFacilitatorTx2 = await ghoContract.addFacilitator(deployer.address, {
    bucketCapacity: "340282366920938463463374607431768211455",
    bucketLevel: 0,
    label: "Ghoul Fuji Facilitator"
  })
  await addFacilitatorTx2.wait(1)

  console.log(`\nFacilitator added ${deployer.address}`)

  // Fund with LINK
  console.log(`\nFunding ${faciliatorContract.address} with ${LINK_AMOUNT} LINK `)
  const linkTokenContract = await ethers.getContractAt("@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20", networks[network.name].linkToken)

  const linkTx = await linkTokenContract.transfer(faciliatorContract.address, ethers.utils.parseUnits(LINK_AMOUNT))
  await linkTx.wait(1)

  const juelsBalance = await linkTokenContract.balanceOf(faciliatorContract.address)
  const linkBalance = ethers.utils.formatEther(juelsBalance.toString())
  console.log(`\nFunded ${faciliatorContract.address} with ${linkBalance} LINK`)
})
