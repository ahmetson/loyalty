// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// An administrative privilege for a certain functions
contract Ownable {
    address public owner;

    event TransferOwnership(address oldOwner, address newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(address _owner) {
        owner = _owner;

        emit TransferOwnership(address(0), _owner);
    }

    function transferOwnership(address _owner) external onlyOwner {
        require(_owner != address(0), "null");

        address oldOwner = owner;

        owner = _owner;

        emit TransferOwnership(oldOwner, _owner);
    }
}
