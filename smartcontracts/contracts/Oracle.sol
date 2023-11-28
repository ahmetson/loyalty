// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./JsSource.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

// Chainlink doesn't work well with the post method.
// Testing it.
abstract contract Oracle is FunctionsClient, JsSource {
    using FunctionsRequest for FunctionsRequest.Request;

    address public chainLinkRouter;
    uint64 public chainLinkSubId;
    bytes32 public chainLinkDonId;
    uint32 public gasLimit = 300000;

    event ErrorResponded(bytes32 requestId, bytes err);

    // @_router see https://docs.chain.link/chainlink-functions/supported-networks
    // for sepolia: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0
    // @_subId Obtained at https://functions.chain.link/sepolia/new
    //        // To obtain the subscription id create an account on the platform.
    //        // Make sure to add UserInterface as the consumer.
    // For us it's 1705.
    // @_donId For the sepolia it's 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000
    constructor(address _router, uint64 _subId, bytes32 _donId) FunctionsClient(_router) {
        chainLinkRouter = _router;
        // Sub ID: 1705.
        chainLinkSubId = _subId;
        // For sepolia:
        chainLinkDonId = _donId;
    }


    function sendRequest(string[] memory args) internal returns(bytes32) {
        require(bytes(jsSource).length > 0, "set js source");

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

        return requestId;
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        // Todo More proper error handling for the production code.
        // How to handle the stuck loyalty points?
        if (err.length > 0) {
            emit ErrorResponded(requestId, err);
            return;
        }

        oracleCallback(requestId, uint256(bytes32(response)));
    }

    // The Loyalty smartcontract must over-write it
    function oracleCallback(bytes32 requestId, uint256 points) internal virtual {}
}

