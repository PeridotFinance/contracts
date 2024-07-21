const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const PeridotToken = await hre.ethers.getContractFactory("PeridotToken");
  const peridotToken = await PeridotToken.deploy();

  await peridotToken.deployed();

  console.log("PeridotToken deployed to:", peridotToken.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
