// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "lib/chainlink-brownie-contracts/contracts/src/v0.8/automation/KeeperCompatible.sol";
import "./mocks/MockProtocols.sol";

contract SmartVault is KeeperCompatibleInterface {
    IERC20 public usdc;
    MockProtocols public mockAave;
    MockProtocols public mockCompound;
    MockProtocols public mockGMX;

    AggregatorV3Interface public aaveAPY;
    AggregatorV3Interface public compoundAPY;
    AggregatorV3Interface public gmxAPY;

    address public owner;
    mapping(address => uint256) public deposits;
    uint256 public currentProtocol = 0; // 1 = Aave, 2 = Compound, 3 = GMX

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(
        address _usdc,
        address _mockAave,
        address _mockCompound,
        address _mockGMX,
        address _aaveAPY,
        address _compoundAPY,
        address _gmxAPY
    ) {
        usdc = IERC20(_usdc);
        mockAave = MockProtocols(_mockAave);
        mockCompound = MockProtocols(_mockCompound);
        mockGMX = MockProtocols(_mockGMX);
        aaveAPY = AggregatorV3Interface(_aaveAPY);
        compoundAPY = AggregatorV3Interface(_compoundAPY);
        gmxAPY = AggregatorV3Interface(_gmxAPY);
        owner = msg.sender;
    }

    /// @notice User deposits USDC into the vault
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        usdc.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    /// @notice User withdraws USDC from the vault
    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        usdc.transfer(msg.sender, amount);
    }

    /// @notice Fetches the best APY protocol to allocate funds
    function getBestAPY() public view returns (uint256 bestProtocol) {
        (, int256 aaveRate,,,) = aaveAPY.latestRoundData();
        (, int256 compoundRate,,,) = compoundAPY.latestRoundData();
        (, int256 gmxRate,,,) = gmxAPY.latestRoundData();

        if (aaveRate >= compoundRate && aaveRate >= gmxRate) return 1;
        if (compoundRate >= aaveRate && compoundRate >= gmxRate) return 2;
        return 3;
    }

    /// @notice Moves funds to the protocol with the best APY
    function rebalance() public onlyOwner {
        uint256 bestProtocol = getBestAPY();
        uint256 vaultBalance = usdc.balanceOf(address(this));

        require(bestProtocol != currentProtocol, "Already in the best protocol");

        // Withdraw from current protocol
        if (currentProtocol == 1) {
            mockAave.withdraw(vaultBalance);
        } else if (currentProtocol == 2) {
            mockCompound.withdraw(vaultBalance);
        } else if (currentProtocol == 3) {
            mockGMX.withdraw(vaultBalance);
        }

        // Deposit into best protocol
        if (bestProtocol == 1) {
            usdc.approve(address(mockAave), vaultBalance);
            mockAave.deposit(vaultBalance);
        } else if (bestProtocol == 2) {
            usdc.approve(address(mockCompound), vaultBalance);
            mockCompound.deposit(vaultBalance);
        } else {
            usdc.approve(address(mockGMX), vaultBalance);
            mockGMX.deposit(vaultBalance);
        }

        currentProtocol = bestProtocol;
    }

    /// @notice Chainlink Keeper check for rebalance trigger
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory data) {
        uint256 bestProtocol = getBestAPY();
        upkeepNeeded = (bestProtocol != currentProtocol);
        data = ""; // Explicitly set data to an empty bytes array
        return (upkeepNeeded, data);
    }

    /// @notice Performs upkeep tasks (rebalance funds)
    function performUpkeep(bytes calldata data) external override {
        (bool upkeepNeeded, ) = this.checkUpkeep(data);
        require(upkeepNeeded, "No need to rebalance");
        rebalance();
    }

    /// @notice Retrieves mock protocol balance of a user
    function getMockBalance(address user) external view returns (uint256) {
        return mockAave.getBalance(user) + mockCompound.getBalance(user) + mockGMX.getBalance(user);
    }
}






