const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const vestingTokenAddress = "0x454296756C64253d2145d0E0231Da79C99cBD360";

  const PeridotVesting = await hre.ethers.getContractFactory("PeridotVesting");
  const peridotVesting = await PeridotVesting.deploy(vestingTokenAddress);

  await peridotVesting.deployed();

  console.log("PeridotVesting deployed to:", peridotVesting.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
