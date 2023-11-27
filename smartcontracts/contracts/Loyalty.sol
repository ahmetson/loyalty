// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Loyalty {
    uint public unlockTime;
    address public owner;
    mapping(address => bool) public shops;

    struct Product {
        uint loyaltyPoints;
        uint expiry;
    }

    // Company -> user -> loyalty points
    mapping(address => mapping(address => uint)) public loyaltyPoints;
    mapping(address => mapping(uint => uint)) public productExpiration;

    event AnnounceLoyaltyPoints(address indexed shop, address indexed user, bytes32 receiptId, uint points, string dataFormat);
    event SubmitPersonalData(address shop, bytes32 receiptId, string userData);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyShop() {
        require(shops[msg.sender], "not_shop");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Todo later we will add a fee mechanism for the Loyalty Service.
    function addShop(address shop) external onlyOwner {
        shops[shop] = true;
    }

    function removeShop(address shop) external onlyOwner {
        delete shops[shop];
    }

    // Shops can remove themselves.
    function removeShop() external onlyShop {
        delete shops[msg.sender];
    }

    // The Shop announces a new exchange for the user data.
    // @user who is receiving the loyalty points
    // @receiptId is the event id that loyalty points given for. It's off-chain event id.
    // @points amount of loyalty points user receives
    // @dataFormat the credential type the shop is asking for.
    function announceLoyaltyPoints(address user, bytes32 receiptId, uint points, string calldata dataFormat) external onlyShop {
        emit AnnounceLoyaltyPoints(msg.sender, user, receiptId, points, dataFormat);
    }

    // Submit Data as a zero-knowledge
    // @shop address of the shop
    // @receiptId bytes32 a payment receipt id
    // @userData is the zero-knowledge proof the user parameters in JSON format.
    function submitPersonalData(address shop, bytes32 receiptId, string calldata userData) external {
        emit SubmitPersonalData(shop, receiptId, userData);
    }
}
