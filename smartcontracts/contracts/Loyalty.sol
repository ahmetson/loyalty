// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Ownable.sol";
import "./Credential.sol";
import "./Shop.sol";
import "./Oracle.sol";
import "./Hex.sol";
import "@turkmenson/user-caring/contracts/UserCaring.sol";

contract Loyalty is Ownable, Credential, Shop, UserCaring, Oracle {
    // init right after announcement.
    // user may reject or submit the data.
    // the confirmed is added by the company.
    enum ExchangeStatus{ INIT, REJECT, SUBMIT, CONFIRMED }

    struct Request {
        address shop;
        bytes32 receiptId;
    }

    struct Exchange {
        address user;
        uint points;
        uint64 credentialId;
        ExchangeStatus status;
        bytes32 requestId;
    }

    // Company -> user -> loyalty points
    mapping(address => mapping(address => uint)) public loyaltyPoints;
    // exchange the data for a loyalty points
    mapping(address => mapping(bytes32 => Exchange)) public exchanges;
    mapping(bytes32 => Request) public requests;

    event AnnounceLoyaltyPoints(address indexed shop, address indexed user, bytes32 receiptId, uint points, uint64 dataFormatId);
    event SubmitPersonalData(address shop, address user, bytes32 receiptId, bytes32 requestId);
    event RejectExchange(address shop, address user, bytes32 receiptId);
    event Exchanged(address shop, address user, bytes32 receiptId);

    // router for sepolia 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0. See the
    // https://docs.chain.link/chainlink-functions/supported-networks
    constructor()
        Ownable(msg.sender)
        UserCaring(0x78220f1C11D91f9B5F21536125201bD1aE5CC676)
        Oracle(0xb83E47C2bC239B3bf370bc41e1459A34b41238D0, 1705,
        0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000) {
    }

    // The Shop initiates an exchange of loyalty points for the user data.
    // @user who is receiving the loyalty points
    // @receiptId is the event id that loyalty points given for. It's off-chain event id.
    // @points amount of loyalty points user receives
    // @dataFormatId the credential type the shop is asking for.
    function announceLoyaltyPoints(address user, bytes32 receiptId, uint points, uint64 credentialId)
        external onlyShop validCredentialId(credentialId) {
        require(user != address(0), "empty user");
        require(receiptId > 0, "receipt id = 0");
        require(points > 0, "0 points");
        require(exchanges[msg.sender][receiptId].user == address(0), "exchange exist");

        exchanges[msg.sender][receiptId] = Exchange(user, points, credentialId, ExchangeStatus.INIT, 0);

        emit AnnounceLoyaltyPoints(msg.sender, user, receiptId, points, credentialId);
    }

    // User continues the exchange initiated at announceLoyaltyPoints.
    // Here user submits the user data asked by the user.
    // By submitting this data, user agrees to send his data in exchange for the loyalty points.
    //
    // The data is turned into submission until the oracles will not finalize them.
    // @shop address of the shop
    // @receiptId bytes32 a receipt id to identify order in off-chain
    // @userData is the zero-knowledge proof the user parameters in JSON format.
    function submitPersonalData(address shop, bytes32 receiptId, string calldata userData) external {
        require(bytes(shops[shop]).length > 0, "shop deleted");

        Exchange storage exchange = exchanges[shop][receiptId];

        require(exchange.user == msg.sender, "not_authorized");
        require(exchange.status == ExchangeStatus.INIT, "invalid_status");

        // Todo send the data to a chainlink
        string[] memory args = new string[](6);
        args[0] = Hex.convert(msg.sender);
        args[1] = Hex.convert(receiptId);
        args[2] = Hex.convert(exchange.credentialId);
        args[3] = userData;
        args[4] = shops[shop];

        exchange.requestId = sendRequest(args);
        exchange.status = ExchangeStatus.SUBMIT;

        requests[exchange.requestId] = Request(shop, receiptId);

        emit SubmitPersonalData(shop, msg.sender, receiptId, exchange.requestId);
    }

    // User rejects the exchange initiated at announceLoyaltyPoints().
    // @shop address of the shop
    // @receiptId bytes32 a receipt id to identify order in off-chain
    function rejectExchange(address shop, bytes32 receiptId) external {
        Exchange storage exchange = exchanges[shop][receiptId];

        require(exchange.user == msg.sender, "not_authorized");
        require(exchange.status == ExchangeStatus.INIT, "invalid status");

        exchange.status = ExchangeStatus.REJECT;

        emit RejectExchange(shop, msg.sender, receiptId);
    }

    function oracleCallback(bytes32 requestId, uint256 points) internal override {
        Request storage request = requests[requestId];

        require(request.shop != address(0), "shop is not set");

        Exchange storage exchange = exchanges[request.shop][request.receiptId];
        require(exchange.status == ExchangeStatus.SUBMIT, "invalid status");

        require(exchange.points == points, "invalid points");

        loyaltyPoints[request.shop][exchange.user] += points;

        // Delete the request
        address shop = request.shop;
        bytes32 receiptId = request.receiptId;
        delete requests[requestId];

        // Finish the exchange
        exchange.status = ExchangeStatus.CONFIRMED;

        emit Exchanged(shop, exchange.user, receiptId);
    }


    // Todo: add the method to spend the loyalty points in a cashback
}
