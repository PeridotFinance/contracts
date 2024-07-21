const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Link libraries to PeridotTokenFactory
  const PeridotTokenFactory = await hre.ethers.getContractFactory(
    "PeridotTokenFactory",
    {
      libraries: {
        PeridotFFTHelper: "0x9aec8CCE977D3270B7760793515f7d295246D204",
        PeridotMiniNFTHelper: "0x458A4f56317d663BA5F31da21BC5BD61Fc3dcB68",
      },
    }
  );

  // Deploy PeridotTokenFactory with linked libraries
  const daoAddress = "0xF450B38cccFdcfAD2f98f7E4bB533151a2fB00E9";
  const swapAddress = "0x8B75a5AbaC9CC0744Dcf37adbc0Aede2d1AEA0E5";
  const vaultAddress = "0xF450B38cccFdcfAD2f98f7E4bB533151a2fB00E9";
  const PFvaultAddress = "0xF450B38cccFdcfAD2f98f7E4bB533151a2fB00E9";
  const peridotTokenFactory = await PeridotTokenFactory.deploy(
    daoAddress,
    swapAddress,
    vaultAddress,
    PFvaultAddress
  );

  await peridotTokenFactory.deployed();
  console.log("PeridotTokenFactory deployed to:", peridotTokenFactory.address);
}

/*
npx hardhat verify --libraries scripts/libraries.js 0x57Db063bD22fcdD3De4f7862Feb19E2CF69D8945 0x772eb2026672499657151aDF84777b6cA9055160 0xF450B38cccFdcfAD2f98f7E4bB533151a2fB00E9
 0x1b667249b006ED58ea9A518C1931346165960C53 0xF450B38cccFdcfAD2f98f7E4bB533151a2fB00E9 0xF450B38cccFdcfAD2f98f7E4bB533151a2fB00E9 --network polygonMu
mbai
*/

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
