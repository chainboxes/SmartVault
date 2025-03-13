// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MockAPYFeed is Ownable {
    uint256 public apy;

    constructor(uint256 _apy, address _owner) Ownable(_owner) {
        apy = _apy;
    }

    function getAPY() external view returns (uint256) {
        return apy;
    }
}
