const { ethers } = require("hardhat");

async function main() {
  // The constructor arguments
  const daoAddress = "0x7A7509A6de1a3BBFC6f61ebE5602346A596254cb";
  const swapAddress = "0x142eDd8c164CA6834a676E2FaC876e25eb526fB3";
  const vaultAddress = "0xF450B38cccFdcfAD2f98f7E4bB533151a2fB00E9";
  const PFvaultAddress = "0xF450B38cccFdcfAD2f98f7E4bB533151a2fB00E9";

  // ABI encoding the constructor arguments
  const encoded = ethers.utils.defaultAbiCoder.encode(
    ["address", "address", "address", "address"],
    [daoAddress, swapAddress, vaultAddress, PFvaultAddress]
  );

  console.log("ABI-encoded constructor arguments:", encoded);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
