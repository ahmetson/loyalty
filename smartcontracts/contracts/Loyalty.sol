// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Ownable.sol";
import "./Credential.sol";
import "./Shop.sol";
import "@turkmenson/user-caring/contracts/UserCaring.sol";

contract Loyalty is Ownable, Credential, Shop, UserCaring {
    // init right after announcement.
    // user may reject or submit the data.
    // the confirmed is added by the company.
    enum ExchangeStatus{ INIT, REJECT, SUBMIT, CONFIRMED }

    struct Exchange {
        address user;
        uint points;
        uint64 dataFormatId;
        ExchangeStatus status;
    }

    // Company -> user -> loyalty points
    mapping(address => mapping(address => uint)) public loyaltyPoints;
    // exchange the data for a loyalty points
    mapping(address => mapping(bytes32 => Exchange)) public exchanges;

    event AnnounceLoyaltyPoints(address indexed shop, address indexed user, bytes32 receiptId, uint points, uint64 dataFormatId);
    event SubmitPersonalData(address shop, address user, bytes32 receiptId);
    event RejectExchange(address shop, address user, bytes32 receiptId);

    constructor() Ownable(msg.sender) UserCaring(0x78220f1C11D91f9B5F21536125201bD1aE5CC676) {}

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

        exchanges[msg.sender][receiptId] = Exchange(user, points, credentialId, ExchangeStatus.INIT);

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
    function submitPersonalData(address shop, bytes32 receiptId, string calldata) external {
        require(exchanges[shop][receiptId].user == msg.sender, "not_authorized");
        require(exchanges[shop][receiptId].status == ExchangeStatus.INIT, "invalid_status");

        exchanges[shop][receiptId].status = ExchangeStatus.SUBMIT;

        // Todo send the data to a chainlink

        emit SubmitPersonalData(shop, msg.sender, receiptId);
    }

    // User rejects the exchange initiated at announceLoyaltyPoints().
    // @shop address of the shop
    // @receiptId bytes32 a receipt id to identify order in off-chain
    function rejectExchange(address shop, bytes32 receiptId) external {
        require(exchanges[shop][receiptId].user == msg.sender, "not_authorized");
        require(exchanges[shop][receiptId].status == ExchangeStatus.INIT, "invalid_status");

        exchanges[shop][receiptId].status = ExchangeStatus.REJECT;

        emit RejectExchange(shop, msg.sender, receiptId);
    }

    // Todo: add the method to spend the loyalty points in a cashback
}
