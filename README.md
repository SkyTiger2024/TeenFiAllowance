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
- **ERC20StreamingEnforcer) (_caveatEnforcer)**      0x56c97aE02f233B29fa03502Ecc0457266d9be00e
- **MockActionsContract (_actionsContract)**:    0x3A4A2B75FA0e9c8dB60bC92A6B0616A3b473def6
- **MockStreamingContract (_streamingContract)**:   0x65e302187f01745Eb8D9bc44CDC361f68d3339d7
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

**Etherscan Links**:
 - TeenFiAllowance: [https://sepolia.etherscan.io/address/0xC77223d1bDEa392Da996E6f9a4aab174fc3aD71F](https://sepolia.etherscan.io/address/0xC77223d1bDEa392Da996E6f9a4aab174fc3aD71F)
 - MockActionsContract: [https://sepolia.etherscan.io/address/0x3A4A2B75FA0e9c8dB60bC92A6B0616A3b473def6](https://sepolia.etherscan.io/address/0x3A4A2B75FA0e9c8dB60bC92A6B0616A3b473def6)
 - MockStreamingContract: [https://sepolia.etherscan.io/address/0x65e302187f01745Eb8D9bc44CDC361f68d3339d7](https://sepolia.etherscan.io/address/0x65e302187f01745Eb8D9bc44CDC361f68d3339d7)
- TestToken: [https://sepolia.etherscan.io/address/0x1230591e26044F0AA562c24b4d7Fd002b227E69c](https://sepolia.etherscan.io/address/0x1230591e26044F0AA562c24b4d7Fd002b227E69c)
        - 
## Innovation and Impact
- **Innovation**: Family-oriented Web3 with dual-token support.
- **Impact**: Simplifies Web3 for non-technical users.
- **Boundaries Pushed**: Full delegation lifecycle with compact UI.

## Challenges and Solutions
- **Challenge**: Contract revert ("Caller is not a parent of the teen").
  - **Solution**: Called `addParent`.
- **Challenge**: Could not get the Delegation Framework to install and work
  - **Solution**: Created the MockDelegationManager
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


## Contract Deployments and Testing
### Contract Deployment Settings:
- **Script**: `DeployTeenFiAllowance.s.sol`
- **Parameters**:
  - `_delegationManager`: `0xdb9B1e94...`
  - `_caveatEnforcer`: `0x56c97aE0...`
  - `_actionsContract`: `0x3A4A2B75...`
  - `_streamingContract`: `0x65e30218...`
- **Network**: Sepolia
- 
### Contract Deployment Steps:
1. **Clone Repository**:
   ```bash
   git clone [Repo URL]
   cd teenfi-allowance
   forge install
   ```
2. **Setup**:
   - Install MetaMask Flask, enable Snaps.[](https://metamask.io/news/hacker-guide-metamask-delegation-toolkit-erc-7715-actions)
   - Set Sepolia RPC in `.env`.
3.**Deploy MockActions & MockStreaming Contracts**:
   ```forge script script\DeployMocks.s.sol --rpc-url https://sepolia.infura.io/v3/68be52d1c6a64ef3b9d7ae3401415bd4 --private-key 0x<YOUR_PRIVATE_KEY> --broadcast

_actionsContract: 0x234202b7EEC7B243fc854c865EAab181B91575D8,
_streamingContract: 0x65e302187f01745Eb8D9bc44CDC361f68d3339d7```
   
4. **Verify Mock Contracts on Sepolia Etherscan**:
   ```forge verify-contract <ACTIONS_CONTRACT_ADDRESS> src/MockActionsContract.sol:MockActionsContract --chain-id 11155111
forge verify-contract <STREAMING_CONTRACT_ADDRESS> src/MockStreamingContract.sol:MockStreamingContract --chain-id 11155111```

5. **Deploy the MockDelegationManager**:
   `forge script script/DeployMockDelegationManager.s.sol --rpc-url https://sepolia.infura.io/v3/68be52d1c6a64ef3b9d7ae3401415bd4 --private-key (key) --broadcast

== Logs ==
  MockDelegationManager deployed to: 0x<MockDelegationManagerAddress>`
   
6. **Update DeployTeenFiAllowance.s.sol with Mock Addresses**:
    `TeenFiAllowance teenFiAllowance = new TeenFiAllowance(
      0xD464A84c5ed04d34B0431464c173b782ae5602F6, // _delegationManager (MockDelegationManager)
      0x56c97aE02f233B29fa03502Ecc0457266d9be00e, // _caveatEnforcer (ERC20StreamingEnforcer)
      0x3A4A2B75FA0e9c8dB60bC92A6B0616A3b473def6, // _actionsContract (MockActionsContract)
      0x65e302187f01745Eb8D9bc44CDC361f68d3339d7 // _streamingContract (MockStreamingContract)`

7. **Deploy the TeenFiAllowance Contract**:
    `forge script script/DeployTeenFiAllowance.s.sol --rpc-url https://sepolia.infura.io/v3/<APIKEY> --private-key (key) --broadcast`
   Note down contract addres:     TeenFiAllowance deployed to: 0x<TeenFiAllownaceContractAddress>

8. **Verify TeenFiAllowance Contract on Etherscan**:
`forge flatten src/TeenFiAllowance.sol > FlatTeenFiAllowance.sol`
Slect Single Solidity file, and paste this contents.

9.  **Update script/TestTeenFi.s.sol with Contract Address**:
    ```address constant TEENFI_ADDRESS = 0x<TeenFiAllownaceContractAddress>;```

10.  **Run Tests**:
   ```bash
   forge script script/TestTeenFi.s.sol --rpc-url https://sepolia.infura.io/v3/<APIKEY> --private-key [YOUR_PRIVATE_KEY] --broadcast

== Logs ==
  Registering parent for teen...
  Parent registered
  Approving TeenFiAllowance for configureAllowance...
  Approval successful
  Calling configureAllowance...
  configureAllowance successful
  Verifying delegation...
  Delegation status: true
  Calling modifyAllowance...
  modifyAllowance successful
   ```

11. **Run dApp**:
   ```bash
   npm run dev
   ```

12. **Query Contract**:
   - Get parents:
     ```bash
     cast call 0x724e4fbe886aC69AE6E4866de4D53639b3723BED "getParents(address)(address[])" 0xfFF8f28f6E86C72FB3c11003dC6c3a05E9ea3E91 --rpc-url https://sepolia.infura.io/v3/<APIKEY>
     ```
   - Get allowance:
     ```bash
     cast call 0x724e4fbe886aC69AE6E4866de4D53639b3723BED "parentTeenAllowances(address,address)(address,uint256,uint256,uint256,bool,uint256)" 0xbB81ae1ca1f3a47fA5CA0A3a44Cd1b195Df65B38 0xfFF8f28f6E86C72FB3c11003dC6c3a05E9ea3E91 --rpc-url https://sepolia.infura.io/v3/生まれ
     ```
13. **View Events**: https://sepolia.etherscan.io/address/0x724e4fbe886aC69AE6E4866de4D53639b3723BED#events

14. **Run Contract Tests**:
   ```bash
   forge script script/TestTeenFi.s.sol --rpc-url https://sepolia.infura.io/v3/[YOUR_INFURA_KEY] --private-key [YOUR_PRIVATE_KEY] --broadcast
   ```
15. **Set Parent-Teen Relationship**:
   ```bash
   cast send 0x4a631b162D58756C2568F03744d63037Bd4348d9 "addParent(address,address)" 0x86110B44E8580905749Eea2A972D15704A914cE5 0x3674473C7BDAf922f68a0232509049aBD37Da7A9 --rpc-url https://sepolia.infura.io/v3/[YOUR_INFURA_KEY] --private-key [DEVAC_PRIVATE_KEY]
   ```




## Front-End Setup Instructions
### Front-EndPrerequisites
- **MetaMask Flask**: Installed and configured for Sepolia testnet.
- **Sepolia ETH**: Obtain test ETH from a faucet (e.g., [Infura Faucet](https://infura.io/faucet)).
- **Node.js**: For local development (optional).
- **Git**: For cloning the repository.
- **mkcert**: For generating local SSL certificates
- **Infura Account**: Required for Sepolia RPC connectivity.

### Front-End Deployment 
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
6. **Deployed Contracts Details** ):
   - Tkae the addresses noted down from when you deplyed `TeenFiAllowance.sol` and `TST.sol`.
   - Update `contractAddress` and `tokenAddress` in `useTSTtokens.html`, `usePYUSDtokens.html`, and `addParent2Teen.html`.
7. **Run the Frontend**:
   - Start the server with SSL:
     ```bash
     npx lite-server --config=bs-config.js
     ```
   - Access at `https://localhost:3000`.

### FrontEnd Usage
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


### FrontEnd Testing
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


## Submission Details
- **Repository**: 
- **Demo Video**: https://github.com/SkyTiger2024/TeenFiAllowance
- **Screenshots**: [Insert URL]
- **Deployed Contracts**:
       `0x2161e095ec52d9B02AdeADFe6cE2A07deF17FF95` (full) 
       `0x4a631b162D58756C2568F03744d63037Bd4348d9` (POC)
- **Front-End Demo URL**: https://www.skytiger.tech/TeenFiAllowance 
- **Team**: SkyTigers
- **Contact**:  info@skytiger.tech
- 
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
