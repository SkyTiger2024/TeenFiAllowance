# TeenFiAllowance POC: Empowering Parental Allowance with ERC-7715 Actions

## Project Overview
**TeenFiAllowance** is a proof-of-concept (POC) decentralized application (dApp) that enables parents to manage weekly allowances for teens using blockchain technology. Built on the Sepolia testnet, leveraging **MetaMask Delegation Toolkit’s ERC-7715 Actions** and **ERC-7710 delegations**,  it supports two ERC-20 tokens: a custom TST token and PayPal USD (PYUSD).
 Parents can configure allowances, set spending caps, and transfer tokens, while teens can spend their allowance within approved categories (e.g., Education, Entertainment). For testing, spent tokens are transferred back to the parent. A minimal HTML front-end supports TST and PYUSD, with clear descriptions, headings, compact side-by-side labeled inputs, pre-filled Teen Address, "Connect MetaMask Flask", "Disconnect Wallet", and "Transfer TST" buttons. 

This repository contains simplified code without demo-specific styling (e.g., Bootstrap) used in the live demo at www.skytiger.tech/TeenFiAllowance/, which includes a styled interface for presentation purposes. 

This project was developed for the ["MetaMask Delegation Toolkit (DTK) Dev Cook-Off"](https://www.hackquest.io/hackathons/MetaMask-Delegation-Toolkit-DTK-Dev-Cook-Off), showcasing blockchain-based financial education for teens, with a user-friendly interface: a demo is hosted at [www.skytiger.tech/TeenFiAllowance/](https://www.skytiger.tech/TeenFiAllowance/).
The live demo is non-working, as the Infura API key has been removed for security reasons. To run the dApp, users must provide their own Infura API key and set up SSL locally, as the frontend requires SSL (HTTPS) to run locally due to MetaMask Flask’s security requirements.

### Hackathon Objective Alignment
Aligns with **Track 1: Best Use of ERC-7715 Actions** by implementing `redeemDelegations` and offering a family-oriented use case.

### Key Features
- **Automated Allowances**: Token streaming via `IERC7715TokenStreaming`.
- **Delegated Spending**: ERC-7715 Actions with `redeemDelegations` (testing in full contract, but bypassed in POC).
- **Security**: OpenZeppelin’s `Ownable`, `ReentrancyGuard`, `SafeERC20`,  emergency **pause** functionality.
- **Front-End**: HTML/JavaScript with Viem (ESM), supporting TST and PYUSD.
- 
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

## Problem Statement
Traditional allowances lack automation, and Web3 dApps require complex approvals.
**TeenFiAllowance** automates payments and delegates spending with a simple UX.

## Solution
- **Contract**: `0x2161e095ec52d9B02AdeADFe6cE2A07deF17FF95` (full) or `0x4a631b162D58756C2568F03744d63037Bd4348d9` (POC).
- **MockDelegationManager**: `0xD464A84c5ed04d34B0431464c173b782ae5602F6`.
- **Test ERC-20 Tokens**:
  - TST: `0x1230591e26044F0AA562c24b4d7Fd002b227E69c`
  - PYUSD: `0xCaC524BcA292aaade2DF8A05cC58F0a65B1B3bB9`
- **Accounts (used only via MetaMask Flask)**:
  - Parent: `0x86110B44E8580905749Eea2A972D15704A914cE5`
  - Teen: `0x3674473C7BDAf922f68a0232509049aBD37Da7A9`
  - TST Owner: `0xbb81ae1ca1f3a47fA5CA0A3a44Cd1b195Df65B38`
- **Front-End**: Homepage with TST/PYUSD links, served over HTTPS.
- **Functions**: `configureAllowance`, `spendAllowance`, `createStreamingAllowance`, `addParent`.

- 
## Technical Details
- **Standards**: ERC-7715, ERC-7710, ERC-20.
- **Dependencies**: OpenZeppelin, Viem (ESM).
- **Delegation**: Live `redeemDelegations` tested; bypassed in POC.
- **Testing**: `TestTeenFi.s.sol` passed.

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

## Innovation and Impact
- **Innovation**: Family-oriented Web3 with dual-token support.
- **Impact**: Simplifies Web3 for non-technical users.
- **Boundaries Pushed**: Full delegation lifecycle with compact UI.

## Challenges and Solutions
- **Challenge**: Contract revert ("Caller is not a parent of the teen").
  - **Solution**: Called `addParent`.
- **Challenge**: Contract revert ("Delegation terms cannot be empty").
  - **Solution**: Set `delegationTerms` to `0x1234`.
- **Challenge**: `teenBalances` timeout.
  - **Solution**: Used Infura RPC with retries.
- **Challenge**: Teen wallet connection failure.
  - **Solution**: Added "Disconnect Wallet" button.
- **Challenge**: Teen has no TST tokens.
  - **Solution**: Added "Transfer TST" button and backend script.

## Future Enhancements
- Achievement rewards, Gator SDK, ERC-4337, NextJS.
- Gasless Transactions: ERC-4337 user operations with a paymaster cover gas fees, enhancing teen accessibility

## Setup Instructions
### Prerequisites
- **MetaMask Flask**: Installed and configured for Sepolia testnet.
- **Sepolia ETH**: Obtain test ETH from a faucet (e.g., [Infura Faucet](https://infura.io/faucet)).
- **Node.js**: For local development (optional).
- **Git**: For cloning the repository.
- **mkcert**: For generating local SSL certificates
- **Infura Account**: Required for Sepolia RPC connectivity.

