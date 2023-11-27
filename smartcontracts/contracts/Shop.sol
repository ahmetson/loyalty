// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Ownable.sol";

abstract contract Shop is Ownable {
    mapping(address => bool) public shops;

    modifier onlyShop() {
        require(shops[msg.sender], "not_shop");
        _;
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
}
