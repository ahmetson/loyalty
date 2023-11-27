import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
    let address = `0x057cec1e4146b1078164cac01f58de84367462b7`;
    const Contract = await ethers.getContractFactory("Post");
    const contract = Contract.attach(address);

    const source = fs
        .readFileSync(path.resolve(__dirname, "post_block_number.txt"))
        .toString();

    console.log(`Setting it up on blockchain`);
    let tx = await contract.setJsSource(source);
    console.log(tx);
    console.log(`Waiting to confirm the transaction: ${tx.hash}`);
    await tx.wait();

    console.log(`JS Source:\n\n`);

    let tokenSource = await contract.jsSource();

    console.log(tokenSource);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});