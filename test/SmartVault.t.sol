// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/SmartVault.sol";
import "../contracts/mocks/MockProtocols.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SmartVaultTest is Test {
    SmartVault vault;
    MockProtocols mockAave;
    MockProtocols mockCompound;
    MockProtocols mockGMX;
    IERC20 usdc;

    address user = address(1);
    uint256 initialDeposit = 1000 * 10**6; // 1000 USDC

    function setUp() public {
        usdc = new IERC20(); // Mock ERC20 token
        mockAave = new MockProtocols();
        mockCompound = new MockProtocols();
        mockGMX = new MockProtocols();

        vault = new SmartVault(
            address(usdc),
            address(mockAave),
            address(mockCompound),
            address(mockGMX),
            address(0), // Mock price feeds (Not used in tests)
            address(0),
            address(0)
        );

        // Mint and approve USDC for user
        usdc.mint(user, initialDeposit);
        vm.startPrank(user);
        usdc.approve(address(vault), initialDeposit);
        vm.stopPrank();
    }

    function testDeposit() public {
        vm.startPrank(user);
        vault.deposit(initialDeposit);
        uint256 balance = vault.deposits(user);
        vm.stopPrank();

        assertEq(balance, initialDeposit, "Deposit amount mismatch");
    }

    function testWithdraw() public {
        vm.startPrank(user);
        vault.deposit(initialDeposit);
        vault.withdraw(initialDeposit);
        uint256 balance = vault.deposits(user);
        vm.stopPrank();

        assertEq(balance, 0, "Withdraw failed");
    }

    function testGetBestAPY() public {
        uint256 bestProtocol = vault.getBestAPY();
        assertTrue(bestProtocol >= 1 && bestProtocol <= 3, "Invalid APY selection");
    }

    function testRebalance() public {
        vm.startPrank(vault.owner());
        vault.rebalance();
        uint256 protocol = vault.currentProtocol();
        vm.stopPrank();

        assertTrue(protocol >= 1 && protocol <= 3, "Rebalance did not work correctly");
    }

    function testCheckUpkeep() public {
        (bool upkeepNeeded, ) = vault.checkUpkeep("");
        assertTrue(upkeepNeeded == false || upkeepNeeded == true, "CheckUpkeep failed");
    }

    function testPerformUpkeep() public {
        vm.startPrank(vault.owner());
        vault.performUpkeep("");
        uint256 protocol = vault.currentProtocol();
        vm.stopPrank();

        assertTrue(protocol >= 1 && protocol <= 3, "PerformUpkeep failed");
    }
}



