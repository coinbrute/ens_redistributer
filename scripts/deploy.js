// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), 'ether')
}

async function main() {
  // Setup accounts & variables
  const [deployer] = await ethers.getSigners()
  const NAME = "ENS Redistributer"
  const SYMBOL = "ENSR"

  // Deploy contract
  const ENSRedistributer = await ethers.getContractFactory("ENSRedistributer")
  const ensRedistributer = await ENSRedistributer.deploy(NAME, SYMBOL)
  await ensRedistributer.deployed();

  console.log(`Deployed Domain Contract at: ${ensRedistributer.address}\n`)

  // List 6 domains
  const names = ["a.eth", "b.eth", "c.eth", "d.eth", "e.eth", "f.eth"]
  const costs = [tokens(10), tokens(25), tokens(15), tokens(2.5), tokens(3), tokens(1)]

  for (var i = 0; i < 6; i++) {
    const transaction = await ensRedistributer.connect(deployer).list(names[i], costs[i])
    await transaction.wait()

    console.log(`Listed Domain ${i + 1}: ${names[i]}`)
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});