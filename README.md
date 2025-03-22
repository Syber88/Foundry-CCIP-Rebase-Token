# Foundry Cross Chain Rebase Token`

# Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/).

1. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

2. Deploy

```
make deploy ARGS="--network sepolia"
```

## Scripts

Instead of scripts, we can directly use the `cast` command to interact with the contract.

For example, on Sepolia:

1. Get some RebaseTokens

```
cast send <vault-contract-address> "deposit()" --value 0.1ether --rpc-url $SEPOLIA_RPC_URL --wallet
```

2. Redeem RebaseTokens for ETH

```
cast send <vault-contractaddress> "redeem(uint256)" 10000000000000000 --rpc-url $SEPOLIA_RPC_URL --wallet
```

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`

# Formatting

To run code formatting:

```
forge fmt
```

# Thank you!

## Project design and assumptions

WHATEVER INTEREST THEY DEPOSIT WITH, THEY STICK WITH

This project is a cross-chain rebase token that integrates Chainlink CCIP to enable users to bridge their tokens cross-chain

### NOTES

- assumed rewards are in contract
- Protocol rewards early users and users which bridge to the L2
  - The interest rate decreases discretely
  - The interest rate when a user bridges is bridges with them and stays static. So, by bridging you get to keep your high interest rate.
- You can only deposit and withdraw on the L1.
- You cannot earn interest in the time while bridging.

Don't forget to bridge back the amount of interest they accrued on the destination chain in that time