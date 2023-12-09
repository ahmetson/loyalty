import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
    let address = `0xC29f0A02d751374b0a92cEBecEb58800EB9a99eC`;
    // let hex = "0x315329244Ca9e2F9E5faB7181f4331f776bf369D";
    // const Contract = await ethers.getContractFactory("Loyalty", {
    //     libraries: {
    //         "Hex": hex,
    //     }
    // });
    const Contract = await ethers.getContractFactory("Loyalty", {});
    const contract = Contract.attach(address);

    const source = fs
        .readFileSync(path.resolve(__dirname, "loyalty_02.txt"))
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