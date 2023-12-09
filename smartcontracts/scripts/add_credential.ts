import { ethers } from "hardhat";

async function main() {
    let address = `0xC29f0A02d751374b0a92cEBecEb58800EB9a99eC`;
    const Contract = await ethers.getContractFactory("Loyalty", {});
    const contract = Contract.attach(address);

    let accounts = await ethers.getSigners();

    // First demo credential:
    const type_1 = "{ id: 1,\n" +
    "      circuitId: CircuitId.AtomicQuerySigV2,\n" +
    "      optional: false,\n" +
    "      query: {\n" +
    "        allowedIssuers: ['*'],\n" +
    "        type: credential.credentialSubject.type,\n" +
    "        context:\n" +
    "        'https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld',\n" +
    "        credentialSubject: {\n" +
    "          birthday: {\n" +
    "            $lt: 20050101,\n" +
    "          },\n" +
    "        },\n" +
    "      },\n" +
    "    }";
    const url_1 = "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld";

    console.log(`Adding the ${url_1}...`);

    let tx = await contract.addCredential(
        new TextEncoder().encode(url_1),
        new TextEncoder().encode(type_1)
    );
    console.log(`Waiting to confirm the transaction: ${tx.hash}`);
    await tx.wait();
    console.log(`Transaction confirmed: ${tx.hash}`);

    const type_2 = JSON.stringify({
        id: 199,
        circuitId: 'credentialAtomicQuerySigV2',
        optional: false,
        query: {
            allowedIssuers: [ '*' ],
            type: 'KYCCountryOfResidence',
            context: 'https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json/KYCCountryOfResidenceCredential-v4.json',
            credentialSubject: {
                countryCode: {
                    $eq: 84
                }
            }
        }
    });
    const url_2 = "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json/KYCCountryOfResidenceCredential-v4.json";

    console.log(`Adding the ${url_2}...`);

    tx = await contract.addCredential(new TextEncoder().encode(url_2), new TextEncoder().encode(type_2));
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