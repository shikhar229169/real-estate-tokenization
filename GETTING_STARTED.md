# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0`
- [yarn](https://yarnpkg.com/getting-started/install)
  - You'll know you did it right if you can run `yarn --version` and you see a response like `1.22.22`
- [node](https://nodejs.org/en/download/)
  - You'll know you did it right if you can run `node --version` and you see a response like `v20.15.0`

### Install Dependencies

```bash
yarn install
forge install
```

### Set up environment variables
Make a .env file and fill it with the following variables.

- AVAX_RPC_URL: RPC Url for Avalanche Fuji Testnet Chain
- AVAX_API_KEY: Block explorer's API Key for Avalanche Chain
- ETHERSCAN_SEPOLIA_RPC_URL: RPC Url for Etherscan Sepolia Testnet Chain
- ETHERSCAN_API_KEY: Block explorer's API Key for Etherscan Chain
- PRIVATE_KEY: Your wallet private key
- PRIVATE_KEY_2: Your secondary wallet private key

### Getting testnet funds for wallet

Testnet funds can be collected from faucets available for the respective chains.
Also, the LINK token for chainlink services for automation and cross-chain interaction can be collected from the faucets.

- Ethereum Sepolia
    - [Alchemy Faucet](https://sepoliafaucet.com/)
    - [Chainlink Faucet](https://faucets.chain.link/)

- Avalanche Fuji
    - [Avalanche Fuji Faucet](https://faucet.avax.network/)
    - [Chainlink Faucet](https://faucets.chain.link/)

### Compiling the contracts

```bash
forge build
yarn hardhat compile
```

### Deployment on Avalanche Fuji

```
source .env
forge script script/DeployAssetTokenizationManager --rpc-url $AVAX_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $AVAX_API_KEY
```

### Deployment on Ethereum Sepolia

```
source .env
forge script script/DeployAssetTokenizationManager --rpc-url $ETHERSCAN_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Setting up of addresses for cross-chain interactions
- Set up cross-chain token addresses for all chains, by calling RealEstateRegistry::setTokenForAnotherChain function
```bash
source .env
cast call <real_estate_registry_address> "setTokenForAnotherChain(address,uint256,address)" <source_token_address> <destination_chain_id> <destination_token_address>  --rpc-url $AVAX_RPC_URL --private-key $PRIVATE_KEY
```

- Allowlist Asset Tokenization Manager of every other chains on each chain by calling AssetTokenizationManager::allowlistManager function
```bash
source .env
cast call <real_estate_registry_address> "allowlistManager(uint64,address)" <chain_selector> <asset_manager>  --rpc-url $AVAX_RPC_URL --private-key $PRIVATE_KEY
```
### Testing

```bash
source .env
anvil --chain-id 43113
forge test --fork-url http://127.0.0.1:8545
```

### Running backend

```bash
sudo mongod --dbpath /var/lib/mongod
npm run local
```

### Running frontend

```bash
npm run start
```