import { ethers } from "hardhat";

async function main() {
    let address = `0xC29f0A02d751374b0a92cEBecEb58800EB9a99eC`;
    const Contract = await ethers.getContractFactory("Loyalty", {});
    const contract = Contract.attach(address);

    let accounts = await ethers.getSigners();

    // let shopAddr = accounts[0].address;
    let shopAddr = "0x02eC83B3666927431faC8Dcb2C490a1a15DDe2eb";
    let shopUrl = "https://loyalty-demo-shop-c06971dc3b2c.herokuapp.com/api/v1/cashback/receive-user-data";


    console.log(`Adding the shop: ${shopAddr}, url: ${shopUrl}`);

    let tx = await contract.addShop(shopAddr, shopUrl);
    console.log(`Waiting to confirm the transaction: ${tx.hash}`);
    await tx.wait();
    console.log(`Transaction confirmed: ${tx.hash}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});