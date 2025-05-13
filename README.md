# TeenFiAllowance POC

## Overview
TeenFiAllowance is a proof-of-concept (POC) decentralized application (dApp) that enables parents to manage weekly allowances for teens using blockchain technology. Built on the Sepolia testnet, it supports two ERC-20 tokens: a custom TST token and PayPal USD (PYUSD). Parents can configure allowances, set spending caps, and transfer tokens, while teens can spend their allowance within approved categories (e.g., Education, Entertainment). For testing, spent tokens are transferred back to the parent.

This repository contains simplified code without demo-specific styling (e.g., Bootstrap) used in the live demo at www.skytiger.tech/TeenFiAllowance/, which includes a styled interface for presentation purposes. 

This project was developed for the ["MetaMask Delegation Toolkit (DTK) Dev Cook-Off"](https://www.hackquest.io/hackathons/MetaMask-Delegation-Toolkit-DTK-Dev-Cook-Off), showcasing blockchain-based financial education for teens, with a user-friendly interface: a demo is hosted at [www.skytiger.tech/TeenFiAllowance/](https://www.skytiger.tech/TeenFiAllowance/).
The live demo is non-working, as the Infura API key has been removed for security reasons. To run the dApp, users must provide their own Infura API key and set up SSL locally, as the frontend requires SSL (HTTPS) to run locally due to MetaMask Flask’s security requirements.

## Features
- **Parent Features**:
  - Registers a parent’s wallet and links it to a teen’s wallet to have delegation authority, enabling the parent to configure allowances and manage spending via the TeenFiAllowance smart contract.
  - Configure weekly allowance and spending cap for a teen’s wallet.
  - Transfer TST or PYUSD tokens to the teen.
- **Teen Features**:
  - View allowance balance and token balance.
  - Spend allowance in approved categories (Education, Entertainment, Savings, Food).
- **Blockchain Integration**:
  - Uses Sepolia testnet for secure, low-cost transactions.
  - Interacts with TeenFiAllowance smart contract and ERC-20 tokens (TST, PYUSD).
- **Responsive UI**:
  - Built with Bootstrap 5 and custom CSS for mobile and desktop compatibility.

## Tech Stack
### Frontend
- **HTML5, CSS3, JavaScript (ES6)**: Core web technologies.
- **Bootstrap 5**: Responsive UI framework.
- **Viem (2.21.25)**: Ethereum client library for contract interactions.
- **MetaMask Flask**: Wallet for Sepolia testnet connectivity.
- **Minimal CSS**: Basic styling for usability, without Bootstrap or external frameworks.
- **lite-server**: Local development server with SSL support.
- **mkcert**: Tool for generating local SSL certificates.

### Blockchain
- **Solidity**: Smart contracts (TeenFiAllowance, TST).
- **Sepolia Testnet**: Ethereum test network (chain ID: `0xaa36a7`).
- **Infura RPC**: `https://sepolia.infura.io/v3/<API-KEY>`.
- **Hardhat/Foundry**: Contract deployment tools.
- **ERC-20**: Standard for TST and PYUSD tokens.

### Deployment
- **Hosting**:  Repository code is simplified; disabled demo with styling hosted on [SkyTiger.Tech](www.skytiger.tech/TeenFiAllowance/) (removed the API key).
- **Contracts**: Deployed on Sepolia, verified on Etherscan.

## Contract Details
- **TeenFiAllowance Contract**:
  - Address: `0x4a631b162D58756C2568F03744d63037Bd4348d9`
  - Functions:
    - `addParent(address parent, address teen)`: Registers a parent’s wallet and links it to a teen’s wallet, granting delegation authority for allowance management.
    - `configureAllowance(address teen, address token, uint256 weeklyAmount, uint256 spendingCap, bytes delegationTerms)`: Sets allowance parameters.
    - `spendAllowance(address parent, uint256 amount, uint8 category)`: Allows teens to spend tokens.
    - `teenBalances(address)`: Returns teen’s allowance balance.
  - Verified on [Sepolia Etherscan](https://sepolia.etherscan.io/address/0x4a631b162D58756C2568F03744d63037Bd4348d9).
- **TST Token (Custom ERC-20)**:
  - Address: `0x1230591e26044F0AA562c24b4d7Fd002b227E69c`
  - Decimals: 18
  - Verified on [Sepolia Etherscan](https://sepolia.etherscan.io/address/0x1230591e26044F0AA562c24b4d7Fd002b227E69c).
- **PYUSD Token (PayPal USD)**:  
  - Address: `0xCaC524BcA292aaade2DF8A05cC58F0a65B1B3bB9` 
  - Decimals: 18
  - Not been verified on [Sepolia Etherscan](https://sepolia.etherscan.io/address/0xCaC524BcA292aaade2DF8A05cC58F0a65B1B3bB9).

## Setup Instructions
### Prerequisites
- **MetaMask Flask**: Installed and configured for Sepolia testnet.
- **Sepolia ETH**: Obtain test ETH from a faucet (e.g., [Infura Faucet](https://infura.io/faucet)).
- **Node.js**: For local development (optional).
- **Git**: For cloning the repository.
- **mkcert**: For generating local SSL certificates
- **Infura Account**: Required for Sepolia RPC connectivity.

### Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repo/TeenFiAllowance.git
   cd TeenFiAllowance
   ```
2. **Install Dependencies** (if running locally):
   ```bash
   npm install lite-server --save-dev
   ```
3. **Set Up Infura API Key**:
   - Sign up at [Infura](https://infura.io/) and create a new Sepolia project.
   - Copy the RPC URL (e.g., `https://sepolia.infura.io/v3/YOUR_API_KEY`).
   - Update the `chain.rpcUrls.default.http` field in the JavaScript code of `useTSTtokens.html`, `usePYUSDtokens.html`, and `addParent2Teen.html` with your RPC URL.
4. **Generate SSL Certificates**:
   - Install `mkcert` (see [mkcert GitHub](https://github.com/FiloSottile/mkcert)).
   - Create a certificate authority (CA):
     ```bash
     mkcert create-ca
     ```
     - Outputs: `ca.key` (CA Private Key), `ca.crt` (CA Certificate).
   - Create a certificate for localhost:
     ```bash
     mkcert create-cert --domains "localhost,127.0.0.1"
     ```
     - Outputs: `cert.key` (Private Key), `cert.crt` (Certificate).
   - Move certificates to the repository root (or update `bs-config.js` paths if stored elsewhere).
5. **Configure lite-server**:
   - Ensure `bs-config.js` is in the repository root with:
     ```javascript
     module.exports = {
       port: 3000,
       open: true,
       server: {
         baseDir: "./",
         https: {
           key: "./cert.key",
           cert: "./ca.crt"
         }
       }
     };
     ```
6. **Deploy Contracts** (if redeploying):
   - Use Hardhat or Foundry to deploy `TeenFiAllowance.sol` and `TST.sol`.
   - Update `contractAddress` and `tokenAddress` in `useTSTtokens.html`, `usePYUSDtokens.html`, and `addParent2Teen.html`.
7. **Run the Frontend**:
   - Start the server with SSL:
     ```bash
     npx lite-server --config=bs-config.js
     ```
   - Access at `https://localhost:3000`.

### Usage
1. **Visit the dApp**: Open `https://localhost:3000` (local) 
2. **Configure Parent-Teen Relationship**:
   - Navigate to the “Configure a new wallet as parent of a teen” page (`addParent2Teen.html`) via the link on the main index page.
   - Connect MetaMask Flask with the parent wallet `0x<ParentsWalletAddress>`
   - Enter the parent wallet address  and teen wallet address 
   - Click “AddParent” to execute `addParent` function in the contract and link the wallets.
3. **Choose Token**:
   - Navigate to TST (`useTSTtokens.html`) or PYUSD (`usePYUSDtokens.html`) page.
4. **Parent Actions (TST Page)**:
   - Set teen address , weekly amount (e.g., 100 TST), and spending cap (e.g., 400 TST).
   - Click “Configure Allowance”.
   - Transfer tokens (e.g., 50 TST) via “Transfer TST to Teen”.
5. **Teen Actions**:
   - Connect teen wallet .
   - View balance and spend allowance (e.g., 25 TST in “Education”).
6. **Verify Transactions**: Check on [Sepolia Etherscan](https://sepolia.etherscan.io/).

## Testing
- **Test Wallets**:
  - Parent: `0x<ParentsWalletAddress>`
  - Teen: `0x<TeensWalletAddress>`
- **Steps**:
  1. Ensure wallets have Sepolia ETH and TST/PYUSD tokens.
  2. On `Configure a new wallet as parent of a teen`, connect parent wallet, enter Parent and Teen addresses, and execute `addParent`.
  3. Configure allowance (100 TST weekly, 400 TST cap).
  4. Transfer 50 TST to teen.
  5. Spend 25 TST as teen in a category.
  6. Verify balances and transactions.
- **Note**: Test when gas fees are low (monitor [Sepolia Gas Tracker](https://sepolia.etherscan.io/gastracker)).

## Contributing
- Fork the repository.
- Create a feature branch (`git checkout -b feature/YourFeature`).
- Commit changes (`git commit -m 'Add YourFeature'`).
- Push to the branch (`git push origin feature/YourFeature`).
- Open a pull request.

## License
MIT License. See [LICENSE](https://github.com/SkyTiger2024/TeenFiAllowance/blob/main/LICENSE) for details.

## Contact
- **Email**: [info@skytiger.tech](mailto:info@skytiger.tech)
- **X**: [@SkyTigerTech](https://x.com/SkyTigerTech)
- **Instagram**: [soratora2024](https://www.instagram.com/soratora2024/)

