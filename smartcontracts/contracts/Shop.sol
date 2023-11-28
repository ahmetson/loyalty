// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Ownable.sol";

abstract contract Shop is Ownable {
    mapping(address => string) public shops;

    modifier onlyShop() {
        require(bytes(shops[msg.sender]).length > 0, "shop not found");
        _;
    }

    // Todo later we will add a fee mechanism for the Loyalty Service.
    function addShop(address shop, string calldata url) external onlyOwner {
        shops[shop] = url;
    }

    function removeShop(address shop) external onlyOwner {
        delete shops[shop];
    }

    // Shops can remove themselves.
    function removeShop() external onlyShop {
        delete shops[msg.sender];
    }
}
