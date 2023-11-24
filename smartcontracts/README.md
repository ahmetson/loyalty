# A Loyalty program.

Network: Sepolia Testnet

Address: [0xb5b9ae9e80bddaa7477eb06785295123a8bdb2cd view on Etherscan](https://sepolia.etherscan.io/address/0xb5b9ae9e80bddaa7477eb06785295123a8bdb2cd#code)

ABI: [Loyalty.json](./abi/contracts/Loyalty.sol/Loyalty.json)

To submit from the wallet the parameters call
`function submitPersonalData(address shop, bytes32 receiptId, string calldata userData)`;

Shop is any random address.
Receipt is any random 32 bytes.
And `userData` is the data in JSON representation of the zero knowledge proof.

