// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

/*
 * Copyright 2019-2020 muth@tu-berlin.de www.dsi.tu-berlin.de
 *
 * MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

import "./BigMod.sol";

contract SmartDiffieHellman {
	using BigMod for uint256;

	uint256 public IV = 0xe7c4ea66ead13384f2c879937dec0dab5230d12a65c81fe7b72ce393ceec48bd;
	uint256 public P = 0xF3EC75CC015A7F458C242E37C292EEF96C40CFB670ED8CFF3BBA27EE3301205B; // openssl dhparam 256 | openssl asn1parse
	uint256 public G = 2;

	function generateA(uint256[] memory _seed) public view returns (uint256 _a, uint256 _A) {
		assert(P != 0);
		assert(G != 0);

		_a = uint256(keccak256(abi.encodePacked(_seed)));
		_A = G.bigMod(_a, P);
	}

	function generateAExtB(uint256 _a, uint256 _B) public view returns (uint256 _AB) {
		_AB = _B.bigMod(_a, P);
	}
}