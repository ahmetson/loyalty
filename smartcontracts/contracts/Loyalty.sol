// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Loyalty {
    uint public unlockTime;
    address public owner;

    struct Product {
        uint loyaltyPoints;
        uint expiry;
    }

    // Company -> user -> loyalty points
    mapping(address => mapping(address => uint)) public loyaltyPoints;
    mapping(address => mapping(uint => uint)) public productExpiration;

    event SubmitPersonalData(address shop, bytes32 receiptId, string userData);

    constructor() {
        owner = msg.sender;
    }

    // Submit Data as a zero-knowledge
    // @shop address of the shop
    // @receiptId bytes32 a payment receipt id
    // @userData is the zero-knowledge proof the user parameters in JSON format.
    function submitPersonalData(address shop, bytes32 receiptId, string calldata userData) external {
        emit SubmitPersonalData(shop, receiptId, userData);
    }
}
