require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("@cronos-labs/hardhat-cronoscan");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config();

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    cronos: {
      url: process.env.REACT_APP_CRO_URL,
      chainId: 25,
      accounts: [process.env.REACT_APP_PRIVATE_KEY_MAIN],
      gasPrice: 5000000000000,
    },
    cronosTestnet: {
      url: process.env.REACT_APP_CRO_TEST_URL,
      chainId: 338,
      accounts: [process.env.REACT_APP_PRIVATE_KEY_TEST],
      gasPrice: 5000000000000,
    },
    polygonMumbai: {
      url: process.env.REACT_APP_MUMBAI_URL,
      accounts: [process.env.REACT_APP_PRIVATE_KEY_TEST],
    },
    sepolia: {
      url: process.env.REACT_APP_SEPOLIA_URL,
      accounts: [process.env.REACT_APP_PRIVATE_KEY_TEST],
    },
  },
  etherscan: {
    apiKey: {
      cronos: process.env.REACT_APP_CRONOSCAN_KEY,
      cronosTestnet: process.env.REACT_APP_CRONOSCAN_TEST_KEY,
      polygonMumbai: process.env.REACT_APP_POLYGONSCAN_KEY,
      sepolia: process.env.REACT_APP_ETHERSCAN_KEY,
    },
  },
  paths: {
    sources: path.join(__dirname, "contracts"),
    artifacts: path.join(__dirname, "artifacts"),
    cache: path.join(__dirname, "cache"),
    tests: path.join(__dirname, "test"),
  },
};
