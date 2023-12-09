import { ethers } from "hardhat";

async function main() {
    let address = `0xC29f0A02d751374b0a92cEBecEb58800EB9a99eC`;
    const Contract = await ethers.getContractFactory("Loyalty", {});
    const contract = Contract.attach(address);

    let accounts = await ethers.getSigners();

    let user = accounts[0].address;
    const receiptId = Date.now().toString();
    const receiptIdStr = receiptId.length > 32 ? receiptId.substring(0, 32) : receiptId;
    // Convert receipt_id to bytes32 hash
    const receiptUtf8Bytes = ethers.toUtf8Bytes(receiptIdStr);
    const receiptBytes = ethers.zeroPadBytes(ethers.hexlify(receiptUtf8Bytes), 32);

    const points = 100;
    const credentialId = 1;

    const acc = new ethers.Wallet(process.env.HARDHAT_VAR_SEPOLIA_PRIVATE_KEY!);
    // const pubKey = acc.signingKey.compressedPublicKey;
    console.log(`${ethers.version} Shop announces a loyalty point in exchange for ${credentialId} data type. Shop gives ${points} points. ReceiptID ${ethers.hexlify(receiptBytes)}`);
    console.log(`Shop private key: ${acc.signingKey.compressedPublicKey}`);

    let tx = await contract.announceLoyaltyPoints(user, receiptBytes, points, credentialId, acc.signingKey.compressedPublicKey);
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