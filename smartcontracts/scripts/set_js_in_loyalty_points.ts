import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
    let address = `0x46725b6712fe03ffbcb77628bd87642945e44377`;
    const Contract = await ethers.getContractFactory("LoyaltyPoints");
    const contract = Contract.attach(address);

    const source = fs
        .readFileSync(path.resolve(__dirname, "loyalty_points.txt"))
        .toString();

    console.log(`Setting it up on blockchain`);
    let tx = await contract.setJsSource(source);
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