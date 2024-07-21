const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log(
    "Deploying PeridotMiniNFTHelper with the account:",
    deployer.address
  );

  const PeridotMiniNFTHelper = await hre.ethers.getContractFactory(
    "PeridotMiniNFTHelper"
  );
  const peridotMiniNFTHelper = await PeridotMiniNFTHelper.deploy();

  await peridotMiniNFTHelper.deployed();
  console.log(
    "PeridotMiniNFTHelper deployed to:",
    peridotMiniNFTHelper.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
