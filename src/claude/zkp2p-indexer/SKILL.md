---
name: zkp2p-indexer
description: Query the ZKP2P on-chain indexer to check intent status, deposits, and transaction history. Use when checking if orders were fulfilled on-chain, investigating intent status, or debugging payment flow issues.
---

# ZKP2P Indexer

## Overview
Query the ZKP2P Hyperindex GraphQL indexer to check on-chain intent and deposit status. Useful for:
- Verifying if an order was fulfilled, pruned, or manually released
- Debugging payment flow issues
- Checking deposit liquidity and stats
- Investigating intent history

## Endpoints

| Environment | URL |
|-------------|-----|
| **Production** | `https://indexer.hyperindex.xyz/8fd74dc/v1/graphql` |
| **Staging** | `https://indexer.hyperindex.xyz/a952e1d/v1/graphql` |

## Quick Start

### Query an Intent by Hash

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(where: {intentHash: {_eq: \"0xYOUR_INTENT_HASH\"}}) { id intentHash status amount paymentAmount fiatCurrency expiryTime fulfillTxHash fulfillTimestamp pruneTxHash pruneTimestamp signalTimestamp toAddress owner isExpired } }"
  }'
```

### Get Recent Intents

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(limit: 10, order_by: {signalTimestamp: desc}) { id intentHash status amount signalTimestamp fulfillTxHash toAddress } }"
  }'
```

## Key Types

### Intent
Represents an on-chain payment intent.

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique ID: `{chainId}_{intentHash}` |
| `intentHash` | String | The intent hash (use for lookups) |
| `status` | IntentStatus | Current status (see below) |
| `amount` | Numeric | Token amount in base units (divide by 10^6 for USDC) |
| `paymentAmount` | Numeric | Fiat payment amount (cents) |
| `fiatCurrency` | String | Currency hash |
| `expiryTime` | Numeric | Unix timestamp when intent expires |
| `signalTimestamp` | Numeric | Unix timestamp when intent was signaled |
| `fulfillTxHash` | String | Transaction hash if fulfilled |
| `fulfillTimestamp` | Numeric | Unix timestamp when fulfilled |
| `pruneTxHash` | String | Transaction hash if pruned |
| `pruneTimestamp` | Numeric | Unix timestamp when pruned |
| `toAddress` | String | Recipient address |
| `owner` | String | Intent owner (relayer) address |
| `isExpired` | Boolean | Whether intent has expired |

### Intent Status Values

| Status | Meaning |
|--------|---------|
| `SIGNALED` | Intent created, awaiting fulfillment |
| `FULFILLED` | Payment verified, funds released to recipient |
| `MANUALLY_RELEASED` | LP manually released funds (proof failed but payment confirmed) |
| `PRUNED` | Intent expired or cancelled, funds returned to LP |

### Deposit
Represents an LP deposit (liquidity).

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique deposit ID |
| `depositId` | Numeric | On-chain deposit ID |
| `depositor` | String | LP address |
| `remainingDeposits` | Numeric | Available liquidity |
| `status` | DepositStatus | Current status |
| `acceptingIntents` | Boolean | Whether accepting new intents |
| `fulfilledIntents` | Int | Count of fulfilled intents |
| `prunedIntents` | Int | Count of pruned intents |
| `successRateBps` | Int | Success rate in basis points |

## Common Queries

### Check Intent Status by Hash

```graphql
query GetIntent($hash: String!) {
  Intent(where: {intentHash: {_eq: $hash}}) {
    id
    intentHash
    status
    amount
    paymentAmount
    expiryTime
    signalTimestamp
    fulfillTxHash
    fulfillTimestamp
    pruneTxHash
    pruneTimestamp
    toAddress
    owner
    isExpired
  }
}
```

### Get Intents for a Recipient

```graphql
query GetRecipientIntents($address: String!) {
  Intent(where: {toAddress: {_eq: $address}}, order_by: {signalTimestamp: desc}) {
    intentHash
    status
    amount
    signalTimestamp
    fulfillTxHash
  }
}
```

### Get Fulfilled Intents (Recent)

```graphql
{
  Intent(
    where: {status: {_eq: "FULFILLED"}},
    order_by: {fulfillTimestamp: desc},
    limit: 20
  ) {
    intentHash
    amount
    paymentAmount
    fulfillTxHash
    fulfillTimestamp
    toAddress
  }
}
```

### Check Deposit Liquidity

```graphql
query GetDeposit($depositor: String!) {
  Deposit(where: {depositor: {_eq: $depositor}}) {
    id
    depositId
    remainingDeposits
    status
    acceptingIntents
    fulfilledIntents
    successRateBps
  }
}
```

### Get Manually Released Intents

```graphql
{
  Intent(
    where: {status: {_eq: "MANUALLY_RELEASED"}},
    order_by: {fulfillTimestamp: desc}
  ) {
    intentHash
    amount
    fulfillTxHash
    fulfillTimestamp
    toAddress
  }
}
```

## Workflow: Debugging an Order

1. **Get the intent hash** from the zkp2p-pay database (`Order.intentHash`)

2. **Query the indexer** for the intent status:
```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{"query": "{ Intent(where: {intentHash: {_eq: \"0xYOUR_HASH\"}}) { status fulfillTxHash pruneTxHash } }"}'
```

3. **Interpret the result**:
   - `FULFILLED` / `MANUALLY_RELEASED` → Order completed on-chain, update DB if needed
   - `PRUNED` → Funds returned to LP, order should be marked EXPIRED/CANCELLED
   - `SIGNALED` → Still awaiting fulfillment

4. **If discrepancy** between indexer and DB:
   - Indexer shows `FULFILLED` but DB shows `EXPIRED` → Update DB to `FULFILLED`
   - Indexer shows `PRUNED` but DB shows `SIGNAL_MINED` → Update DB to `EXPIRED`

## Notes

- Intent IDs are formatted as `{chainId}_{intentHash}` (e.g., `8453_0xabc...`)
- Amounts are in base units (USDC has 6 decimals, so divide by 1,000,000)
- Payment amounts are typically in cents
- Timestamps are Unix epoch seconds
- Use `intentHash` field for lookups, not `id`

## References
- See `references/schema.md` for full GraphQL schema
- See `references/examples.md` for more query examples
