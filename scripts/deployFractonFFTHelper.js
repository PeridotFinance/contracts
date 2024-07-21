const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying PeridotFFTHelper with the account:", deployer.address);

  const PeridotFFTHelper = await hre.ethers.getContractFactory(
    "PeridotFFTHelper"
  );
  const peridotFFTHelper = await PeridotFFTHelper.deploy();

  await peridotFFTHelper.deployed();
  console.log("PeridotFFTHelper deployed to:", peridotFFTHelper.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
