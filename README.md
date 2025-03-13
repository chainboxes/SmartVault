🛡️ Smart Vault - Decentralized Yield Optimizer
A yield-optimizing vault that automatically deposits USDC into the best-performing DeFi protocols (Aave, Compound, GMX) based on their APY (Annual Percentage Yield).

🔹 Automated Fund Rebalancing 🔄
🔹 Secure Deposits & Withdrawals 🔐
🔹 Uses Chainlink Keepers for Upkeep ⛓️

📌 Features
✅ Deposit & Withdraw USDC: Users can deposit and withdraw USDC at any time.
✅ Automated Rebalancing: The contract moves funds to the best APY protocol.
✅ Chainlink Keepers: Monitors and executes fund allocation automatically.
✅ Mock Protocols for Testing: No real DeFi protocol interaction needed.

📂 Project Structure
📜 SmartVault.sol - The core contract handling deposits, withdrawals, and rebalancing.
📜 mocks/MockProtocols.sol - Simulates Aave, Compound, and GMX for testing.
🧪 test/SmartVault.t.sol - Contains test cases written in Foundry.

🧪 Running Tests
This project includes tests for deposit and withdraw functions. Other functions like testGetBestAPY(), testCheckUpkeep(), and testPerformUpkeep() require real price feed addresses, so they are omitted for educational purposes.

Run Tests Locally 🛠️
sh
Copy
Edit
forge test
✅ Test Coverage

testDeposit() 🟢 Passed
testWithdraw() 🟢 Passed
Other tests require real price feeds, so they are not included.
🚀 Deployment
To deploy the contract locally using Foundry


📜 License
This project is open-source under the MIT License. Feel free to use, modify, and share!

🌟 Contribute & Connect
If you find this project useful, star this repo ⭐ and share your feedback!  

