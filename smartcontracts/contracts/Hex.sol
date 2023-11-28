// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Strings.sol";

library Hex {
    // Taken from
    // https://www.appsloveworld.com/ethereum/32/convert-bytes-to-hexadecimal-string-in-solidity
    function convert(bytes32 buffer) public pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(64 * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(abi.encodePacked("0x", converted));
    }

    function convert(uint num) public pure returns (string memory) {
        return Strings.toString(num); // user
    }

    function convert(address addr) public pure returns (string memory) {
        return Strings.toHexString(addr);
    }
}