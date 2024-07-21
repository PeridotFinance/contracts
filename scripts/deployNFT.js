const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const NFT = await hre.ethers.getContractFactory("NFT");
  const nFT = await NFT.deploy();

  await nFT.deployed();

  console.log("NFT deployed to:", nFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
