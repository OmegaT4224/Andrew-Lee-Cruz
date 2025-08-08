require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

// Creator: Andrew Lee Cruz
// License: All rights reserved by Andrew Lee Cruz as creator of the universe

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      chainId: 1337,
      accounts: {
        count: 10,
        accountsBalance: "10000000000000000000000", // 10,000 ETH
      },
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 1337,
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "https://sepolia.infura.io/v3/",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
    },
    mainnet: {
      url: process.env.MAINNET_RPC_URL || "https://mainnet.infura.io/v3/",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 1,
    },
    polygon: {
      url: process.env.POLYGON_RPC_URL || "https://polygon-rpc.com/",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 137,
    },
    // PoAI testnet (placeholder for future deployment)
    poai: {
      url: process.env.POAI_RPC_URL || "http://localhost:26657",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 2024,
    },
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      sepolia: process.env.ETHERSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
    token: "ETH",
    gasPriceApi: "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
  mocha: {
    timeout: 60000, // 60 seconds
  },
  defaultNetwork: "hardhat",
  // Creator attribution in contract metadata
  metadata: {
    creator: "Andrew Lee Cruz",
    uid: "andrew-lee-cruz-creator-universe-2024",
    license: "All rights reserved by Andrew Lee Cruz as creator of the universe",
    project: "PoAI Zero-Mining Blockchain",
    created: "2024-08-08T14:42:00Z",
  },
};