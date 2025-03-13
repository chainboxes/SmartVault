// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/SmartVault.sol";
import "../src/mocks/MockAPYFeed.sol";
import "../src/mocks/MockProtocols.sol";
import "../src/mocks/MockERC20.sol";

contract DeploySmartVault is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy MockERC20
        MockERC20 usdc = new MockERC20();

        // Deploy MockProtocols
        MockProtocols mockAave = new MockProtocols(address(usdc));
        MockProtocols mockCompound = new MockProtocols(address(usdc));
        MockProtocols mockGMX = new MockProtocols(address(usdc));

        // Deploy MockAPYFeed
        address owner = msg.sender;
        MockAPYFeed mockAaveAPY = new MockAPYFeed(5 * 1e18, owner);  // 5% APY
        MockAPYFeed mockCompoundAPY = new MockAPYFeed(4 * 1e18, owner); // 4% APY
        MockAPYFeed mockGMXAPY = new MockAPYFeed(6 * 1e18, owner); // 6% APY

        // Deploy SmartVault
        SmartVault vault = new SmartVault(
            address(usdc),
            address(mockAave),
            address(mockCompound),
            address(mockGMX),
            address(mockAaveAPY),
            address(mockCompoundAPY),
            address(mockGMXAPY)
        );

        vm.stopBroadcast();
    }
}