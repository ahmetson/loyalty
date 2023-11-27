import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
    let address = `0x057cec1e4146b1078164cac01f58de84367462b7`;
    const Contract = await ethers.getContractFactory("Post");
    const contract = Contract.attach(address);

    console.log(`Submitting a request to fetch block number`);
    let tx = await contract.fetchBlockNumber();
    console.log(`Waiting to confirm the transaction: ${tx.hash}`);
    await tx.wait();

    console.log(`Waiting for the event from the chainlink\n\n`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});