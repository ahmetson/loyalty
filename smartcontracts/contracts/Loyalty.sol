// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Loyalty {
    // init right after announcement.
    // user may reject or submit the data.
    // the confirmed is added by the company.
    enum ExchangeStatus{ INIT, REJECT, SUBMIT, CONFIRMED }

    uint public unlockTime;
    address public owner;
    mapping(address => bool) public shops;

    struct Product {
        uint loyaltyPoints;
        uint expiry;
    }

    struct Exchange {
        address user;
        uint points;
        string dataFormat;
        ExchangeStatus status;
    }

    // Company -> user -> loyalty points
    mapping(address => mapping(address => uint)) public loyaltyPoints;
    mapping(address => mapping(uint => uint)) public productExpiration;
    mapping(address => mapping(bytes32 => Exchange)) public exchanges; // exchange the data for a loyalty points

    event AnnounceLoyaltyPoints(address indexed shop, address indexed user, bytes32 receiptId, uint points, string dataFormat);
    event SubmitPersonalData(address shop, address user, bytes32 receiptId);

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
        require(user != address(0), "empty_user");
        require(receiptId > 0, "receipt_id = 0");
        require(points > 0, "0 points");
        require(exchanges[msg.sender][receiptId].user == address(0), "exchange exist");

        exchanges[msg.sender][receiptId] = Exchange(user, points, dataFormat, ExchangeStatus.INIT);

        emit AnnounceLoyaltyPoints(msg.sender, user, receiptId, points, dataFormat);
    }

    // Submit Data as a zero-knowledge
    // @shop address of the shop
    // @receiptId bytes32 a receipt id to identify order in off-chain
    // @userData is the zero-knowledge proof the user parameters in JSON format.
    function submitPersonalData(address shop, bytes32 receiptId, string calldata userData) external {
        require(exchanges[shop][receiptId].user == msg.sender, "not_authorized");
        require(exchanges[shop][receiptId].status == ExchangeStatus.INIT, "invalid_status");

        exchanges[shop][receiptId].status = ExchangeStatus.SUBMIT;

        // Todo send the data to a chainlink

        emit SubmitPersonalData(shop, msg.sender, receiptId);
    }
}
