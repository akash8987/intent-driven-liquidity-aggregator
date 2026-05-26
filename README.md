# Intent-Driven Liquidity Aggregator

In the cross-chain, multi-rollup paradigm of 2026, forcing users to manually select routing paths across distinct Liquidity Pools (LPs) is obsolete. This repository implements an **Intent-Driven DEX Aggregator** where users sign off-chain token swap intents rather than executing rigid transactions.

## How it Works
1. **Intent Formulation:** The user signs an EIP-712 payload stating their constraints (e.g., "Swap 10 ETH for at least 32,000 USDC").
2. **Solver Competition:** Off-chain Solvers compete to find the most efficient routing path across Uniswap v4 hooks, Curve, and Balancer.
3. **CoW (Coincidence of Wants):** The engine cross-matches incoming user intents internally to settle trades without touching on-chain slippage, falling back on AMM routes only when necessary.

## Getting Started
1. Install project dependencies: `npm install`
2. Spin up a local hardhat/foundry network.
3. Execute the matching engine simulation script: `node batchMatcher.js`

## Tech Stack
- Solidity ^0.8.26
- Ethers.js v6
- Node.js
