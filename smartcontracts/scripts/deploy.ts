import { ethers, network } from "hardhat";

async function main() {
  // const libAddr = "0x315329244Ca9e2F9E5faB7181f4331f776bf369D";
  // const loyalty = await ethers.deployContract("Loyalty", [], {libraries: {"Hex": libAddr}});
  const loyalty = await ethers.deployContract("Loyalty", []);
  console.log('Waiting for a confirmation of Loyalty deployment');

  await loyalty.waitForDeployment();
  let loyaltyAddr = await loyalty.getAddress();
  console.log(`Loyalty deployed to ${loyaltyAddr}`);
  console.log(`What's next?`);
  console.log(`\t1. Verify the contract calling 'npx hardhat verify --network ${network.name} ${loyaltyAddr}'`);
  console.log(`\t2. Set the JS function calling (edit the script to set the contract address) 'npx hardhat run --network ${network.name} scripts/set_js_in_loyalty.ts'`);
  console.log(`\t3. Add the smartcontract as the consumer in the Chainlink function: https://functions.chain.link/sepolia/1705`);
  console.log(`\t4. Export ABI using 'npx hardhat export-abi'`);
  console.log(`\t5. Update README to show the deployed smartcontracts for publicity`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
