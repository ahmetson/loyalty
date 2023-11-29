import { ethers, network } from "hardhat";

async function main() {
  const hexLib = await ethers.deployContract("Hex", { });
  console.log(`Waiting for a confirmation of hex deployment`);

  let libRes = await hexLib.waitForDeployment();

  let libAddr = await libRes.getAddress();
  console.log(`Hex library deployed to ${libAddr}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
