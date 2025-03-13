// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockProtocols {
    IERC20 public token;
    mapping(address => uint256) public balances;

    constructor(address _token) {
        token = IERC20(_token);
    }

    /// @notice Simulates deposit into a mock protocol
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }

    /// @notice Simulates withdrawal from a mock protocol
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

    /// @notice Returns the user's balance in the protocol
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}

