# ZKP2P Indexer Query Examples

## Intent Queries

### Get Intent by Hash (Most Common)

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(where: {intentHash: {_eq: \"0x0f4509f498ec7513867165d87c6ab84c5fbaceb92aa04b576ab99dd25a461879\"}}) { id intentHash status amount paymentAmount fulfillTxHash fulfillTimestamp pruneTxHash toAddress owner isExpired } }"
  }'
```

### Get Recent Intents (Last 20)

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(limit: 20, order_by: {signalTimestamp: desc}) { intentHash status amount signalTimestamp fulfillTxHash toAddress } }"
  }'
```

### Get Fulfilled Intents Only

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(where: {status: {_eq: \"FULFILLED\"}}, order_by: {fulfillTimestamp: desc}, limit: 20) { intentHash amount fulfillTxHash fulfillTimestamp toAddress } }"
  }'
```

### Get Manually Released Intents

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(where: {status: {_eq: \"MANUALLY_RELEASED\"}}, order_by: {fulfillTimestamp: desc}) { intentHash amount fulfillTxHash fulfillTimestamp toAddress } }"
  }'
```

### Get Pruned/Expired Intents

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(where: {status: {_eq: \"PRUNED\"}}, order_by: {pruneTimestamp: desc}, limit: 20) { intentHash amount pruneTxHash pruneTimestamp toAddress owner } }"
  }'
```

### Get Intents for a Recipient Address

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(where: {toAddress: {_eq: \"0xaDdA73F5d72dFeEFC028a657c7f18e3986aB2Fd2\"}}, order_by: {signalTimestamp: desc}) { intentHash status amount signalTimestamp fulfillTxHash } }"
  }'
```

### Get Intents by Owner (Relayer)

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(where: {owner: {_eq: \"0xa4152975230b5dc505A96CB24bDe2a15a3678e8E\"}}, order_by: {signalTimestamp: desc}, limit: 50) { intentHash status amount signalTimestamp fulfillTxHash toAddress } }"
  }'
```

### Get Signaled (Pending) Intents

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Intent(where: {status: {_eq: \"SIGNALED\"}}, order_by: {signalTimestamp: desc}) { intentHash amount expiryTime signalTimestamp toAddress owner isExpired } }"
  }'
```

## Deposit Queries

### Get All Active Deposits

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Deposit(where: {status: {_eq: \"ACTIVE\"}}) { id depositId depositor remainingDeposits acceptingIntents fulfilledIntents successRateBps } }"
  }'
```

### Get Deposit by Depositor Address

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Deposit(where: {depositor: {_eq: \"0x...\"}}) { id depositId remainingDeposits outstandingIntentAmount totalAmountTaken fulfilledIntents prunedIntents successRateBps } }"
  }'
```

### Get Deposits with Intents

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Deposit(limit: 5) { id depositId depositor remainingDeposits intents(limit: 5, order_by: {signalTimestamp: desc}) { intentHash status amount } } }"
  }'
```

## Stats Queries

### Get Maker (LP) Stats

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ MakerStats(order_by: {totalProfit: desc}, limit: 10) { id totalDeposits currentDeposits totalIntents fulfilledIntents successRateBps totalProfit } }"
  }'
```

### Get Taker Stats

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ TakerStats(order_by: {totalVolume: desc}, limit: 10) { id totalIntents fulfilledIntents prunedIntents totalVolume } }"
  }'
```

## Event Queries

### Get Recent Signal Events

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Orchestrator_V21_IntentSignaled(order_by: {timestamp: desc}, limit: 10) { intentHash owner to amount transactionHash timestamp } }"
  }'
```

### Get Recent Fulfill Events

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ Orchestrator_V21_IntentFulfilled(order_by: {timestamp: desc}, limit: 10) { intentHash paymentAmount releasedAmount transactionHash timestamp } }"
  }'
```

## Aggregation Examples

### Count Intents by Status

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "{ fulfilled: Intent_aggregate(where: {status: {_eq: \"FULFILLED\"}}) { aggregate { count } } pruned: Intent_aggregate(where: {status: {_eq: \"PRUNED\"}}) { aggregate { count } } signaled: Intent_aggregate(where: {status: {_eq: \"SIGNALED\"}}) { aggregate { count } } }"
  }'
```

## Using with jq

### Pretty Print Response

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{"query": "{ Intent(limit: 5) { intentHash status amount } }"}' | jq
```

### Extract Just the Data

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{"query": "{ Intent(limit: 5) { intentHash status } }"}' | jq '.data.Intent'
```

### Filter by Status Locally

```bash
curl -s -X POST 'https://indexer.hyperindex.xyz/8fd74dc/v1/graphql' \
  -H 'Content-Type: application/json' \
  -d '{"query": "{ Intent(limit: 100) { intentHash status amount } }"}' | jq '.data.Intent | map(select(.status == "FULFILLED"))'
```

## Notes

- Production endpoint: `https://indexer.hyperindex.xyz/8fd74dc/v1/graphql`
- Staging endpoint: `https://indexer.hyperindex.xyz/a952e1d/v1/graphql`
- All amounts in base units (divide by 1000000 for USDC dollar amount)
- Timestamps in Unix seconds
- Use `intentHash` for lookups, not `id`
