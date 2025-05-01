require('dotenv').config();
require('@nomiclabs/hardhat-etherscan');
require('@nomiclabs/hardhat-waffle');

module.exports = {
  defaultNetwork: "mumbai",
  networks: {
    mumbai: {
      url: process.env.MUMBAI_RPC,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};