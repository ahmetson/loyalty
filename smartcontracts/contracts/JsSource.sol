// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Ownable.sol";

// For testing purpose to incrementally improve the code
// We are adding a way to set the JavaScript source code.
abstract contract JsSource is Ownable {
    string public jsSource = "";

    function setJsSource(string calldata _source) external onlyOwner {
        jsSource = _source;
    }
}

