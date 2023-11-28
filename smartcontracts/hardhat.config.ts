import dotenv from "dotenv";
dotenv.config({path: '../.env'});

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";
import "hardhat-abi-exporter"

const SEPOLIA_RPC = process.env.HARDHAT_VAR_SEPOLIA_RPC as string;
const SEPOLIA_PRIVATE_KEY = process.env.HARDHAT_VAR_SEPOLIA_PRIVATE_KEY as string;

const config: HardhatUserConfig = {
  etherscan: {
    apiKey: process.env.HARDHAT_VAR_ETHERSCAN as string,
    enabled: true,
  },
  sourcify: {
    enabled: true,
  },
  solidity: {
    version: "0.8.22",
    settings: {
      optimizer: {enabled: true, runs: 200}
    }
  },
  networks: {
    sepolia: {
      url: SEPOLIA_RPC,
      accounts: [SEPOLIA_PRIVATE_KEY]
    },
  },
};

export default config;
