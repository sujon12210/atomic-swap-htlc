# Atomic Swap (HTLC)

A professional-grade implementation of Hashed Timelock Contracts. This repository enables two parties to exchange assets across different blockchains (or the same chain) safely. If one party fails to fulfill their end of the bargain, the assets are automatically refunded via a cryptographic timeout.

## Core Mechanisms
* **Hashed Lock:** Assets are locked with a keccak256 hash. They can only be unlocked by providing the original "preimage" (secret).
* **Time Lock:** If the secret is not provided within a specific timeframe (e.g., 24 hours), the depositor can reclaim their funds.
* **Trustless:** No escrow agent or middleman is required; the math enforces the contract.

## Workflow
1. **Alice** generates a secret and hashes it. She locks her funds in an HTLC with that hash.
2. **Bob** locks his funds in a separate HTLC using the *same* hash.
3. **Alice** claims Bob's funds by revealing the secret.
4. **Bob** sees the secret on-chain and uses it to claim Alice's funds.

## Setup
1. `npm install`
2. Deploy `AtomicSwap.sol`.
3. Use `swap-test.js` to simulate the hash-reveal flow.
