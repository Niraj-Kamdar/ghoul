const { networks } = require("../networks")
const { fs } = require('fs')

task("setup-messenger", "deploy Messenger.sol").setAction(async (taskArgs, hre) => {
  if (network.name === "hardhat") {
    throw Error("This command cannot be used on a local development chain.  Specify a valid network.")
  }
  if (network.name !== "fuji" && network.name !== 'sepolia' && network.name !== 'mumbai') {
    throw Error("This task is intended to be executed on the Fuji, Sepolia, or Mumbai networks.")
  }

  // addresses
  const owner = (await ethers.getSigners())[0].address
  const FACTORY = owner
  const ROUTER = networks[network.name].router
  const LINK = networks[network.name].linkToken

  // token amounts
  // const TOKEN_TRANSFER_AMOUNT = "0.0001"
  // const LINK_AMOUNT = "0.5"

  console.log("\n__Compiling Contracts__")
  await run("compile")

  console.log(`\nDeploying Encoder.sol to ${network.name}...`)
  const encoderFactory = await ethers.getContractFactory("Encoder")
  const encoderContract = await encoderFactory.deploy()
  await encoderContract.deployTransaction.wait(1)

  console.log(`\nEncoder contract is deployed to ${network.name} at ${encoderContract.address}`)

  console.log(`\nDeploying Messenger.sol to ${network.name}...`)
  const messengerFactory = await ethers.getContractFactory("Messenger", {
    libraries: {
      Encoder: encoderContract.address,
    },
  })
  const messengerContract = await messengerFactory.deploy(FACTORY, owner, ROUTER, LINK)
  await messengerContract.deployTransaction.wait(1)

  console.log(`\nMessenger contract is deployed to ${network.name} at ${messengerContract.address}`)

  fs.writeFileSync(
    `contractDeployments/deployments_${network.name}.json`,
    JSON.stringify({
      messenger: messengerContract.address,
      encoder: encoderContract.address
    }, null, 2),
    'utf-8'
  )

  // Fund with LINK
  // console.log(`\nFunding ${senderContract.address} with ${LINK_AMOUNT} LINK `)
  // const linkTokenContract = await ethers.getContractAt("LinkTokenInterface", networks[network.name].linkToken)
  //
  // const linkTx = await linkTokenContract.transfer(senderContract.address, ethers.utils.parseUnits(LINK_AMOUNT))
  // await linkTx.wait(1)
  //
  // const juelsBalance = await linkTokenContract.balanceOf(messengerContract.address)
  // const linkBalance = ethers.utils.formatEther(juelsBalance.toString())
  // console.log(`\nFunded ${messengerContract.address} with ${linkBalance} LINK`)
})
