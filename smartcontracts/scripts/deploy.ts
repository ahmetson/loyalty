import { ethers } from "hardhat";

async function main() {
  const loyalty = await ethers.deployContract("Loyalty", []);

  console.log(
    `Loyalty deployed to ${loyalty.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
