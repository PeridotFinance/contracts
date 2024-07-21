const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // You need to replace these addresses with the actual addresses you intend to use
  const _witnetRandomness = "0x0123456fbBC59E181D76B6Fe8771953d1953B51a";

  const PeridotSwap = await hre.ethers.getContractFactory("PeridotSwap");
  const peridotSwap = await PeridotSwap.deploy(_witnetRandomness);

  await peridotSwap.deployed();

  console.log("PeridotSwap deployed to:", peridotSwap.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
