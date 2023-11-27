// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

// Chainlink doesn't work well with the post method.
// Testing it.
contract LoyaltyPoints is FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    string public jsSource = "";

    address public chainLinkRouter;
    uint64 public chainLinkSubId;
    bytes32 public chainLinkDonId;
    uint32 public gasLimit = 300000;

    mapping(string => uint256) public loyaltyPoints;
    mapping(bytes32 => string) public requests;

    event Request(address indexed caller, bytes32 indexed requestId);
    event Response(bytes32 indexed requestId, bytes response, bytes err);

    constructor() FunctionsClient(0xb83E47C2bC239B3bf370bc41e1459A34b41238D0) {
        // for sepolia 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0. See the
        // https://docs.chain.link/chainlink-functions/supported-networks
        chainLinkRouter = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
        // Sub ID: 1705. Obtained at https://functions.chain.link/sepolia/new
        // To obtain the subscription id create an account on the platform.
        // Make sure to add UserInterface as the consumer.
        chainLinkSubId = 1705;
        // For sepolia:
        chainLinkDonId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    }


    function setJsSource(string calldata _source) external {
        jsSource = _source;
    }

    function fetchLoyaltyPoints(string calldata productId) external {
        require(bytes(jsSource).length > 0, "set js source");

        string[] memory args = new string[](1);
        args[0] = productId;

        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(jsSource); // Initialize the request with JS code
        req.setArgs(args);

        // Send the request and store the request ID
        bytes32 requestId = _sendRequest(
            req.encodeCBOR(),
            chainLinkSubId,
            gasLimit,
            chainLinkDonId
        );

        requests[requestId] = productId;

        emit Request(msg.sender, requestId);
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        emit Response(requestId, response, err);
        if (response.length > 0) {
            loyaltyPoints[requests[requestId]] = uint256(bytes32(response));
            delete requests[requestId];
        }
    }
}

