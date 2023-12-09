import { ethers } from "hardhat";
import { encrypt as ecEncrypt } from "eccrypto";

type PassedEcies = {
    iv: string;
    ephemPublicKey: string;
    ciphertext: string;
    mac: string;
};

async function main() {
    let address = `0xC29f0A02d751374b0a92cEBecEb58800EB9a99eC`;
    const Contract = await ethers.getContractFactory("Loyalty", {});
    const contract = Contract.attach(address);

    // Fetch the public key
    // const fromBlock = 4851151;
    // const toBlock = 4851151;
    // const logs = await contract.queryFilter("AnnounceLoyaltyPoints", fromBlock, toBlock);
    // const pubKey = Buffer.from(logs[0].args[5], "hex");
    const pubKey = Buffer.from("0x036e731dd51bbcf5a009f2e4d19d5a17de0eb3248e529977ede072bf291d8c78fe".substring(2), "hex");

    let accounts = await ethers.getSigners();

    const shop = accounts[0].address;
    const receiptId = Uint8Array.from(Buffer.from("0x30393132323331313439504d0000000000000000000000000000000000000000".substring(2), 'hex'));

    const anonData = {
        "id": 1,
        "circuitId": "credentialAtomicQuerySigV2",
        "proof": {
        "pi_a": [
            "9965151389553352611759318006315256079789217631768251584028511960030230168874",
            "11696486750767254364618505790731705679781708707960711030780122624527067209861",
            "1"
        ],
            "pi_b": [
            [
                "6177168010191726975598655099571873161897241726779381804412620794902664764488",
                "7038381218247630350207828526472170629077031102093336841203448083856676379523"
            ],
            [
                "21215713892302498318512049759963070883265987807952896116088287086680786191894",
                "8715172853733164502454957901955508008621959348367712436261089124729400973524"
            ],
            [
                "1",
                "0"
            ]
        ],
            "pi_c": [
            "17290451202614154888263428473950780957211488341291549029259942422436124580386",
            "7417134501242802871142426548714117105340912921578784000250141808694907338566",
            "1"
        ],
            "protocol": "groth16",
            "curve": "bn128"
        },
        "pub_signals": [
            "1",
            "23073067765382530941073328771230040043716751865703435297947114792704152066",
            "13862385811284275521365148437425518223873796207972309717232872679418733783147",
            "1",
            "23632405753992911422600055802952338576782959776601866697121858627544224258",
            "1",
            "21707965367085448271828511060467677521286186728247995090956597460824571693894",
            "1701764859",
            "74977327600848231385663280181476307657",
            "0",
            "20376033832371109177683048456014525905119173674985843915445634726167450989630",
            "0",
            "2",
            "20050101",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0",
            "0"
     ]
    }
    const points = 100;
    const credentialId = 1;

    const cipher = await ecEncrypt(pubKey, Buffer.from(JSON.stringify(anonData)));

    console.log(`User submits the data for receipt id ${receiptId}...`);

    const cipherText: PassedEcies = {
        ciphertext: ethers.hexlify(cipher.ciphertext),
        iv: ethers.hexlify(cipher.iv),
        ephemPublicKey: ethers.hexlify(cipher.ephemPublicKey),
        mac: ethers.hexlify(cipher.mac),
    };

    let tx = await contract.submitPersonalData(shop, receiptId, JSON.stringify(cipherText));
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