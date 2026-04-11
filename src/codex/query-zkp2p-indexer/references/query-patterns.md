# Query Patterns

Use production unless the user explicitly asks for staging or fixtures:

- `https://indexer.zkp2p.xyz/v1/graphql`

All requests are GraphQL POSTs with:

```json
{"query":"...","variables":{}}
```

## Data Conventions

- Amounts are serialized as decimal strings
- USDC uses 6 decimals, so `"1000000"` means `1 USDC`
- Rates use `1e18` fixed point, so `"1000000000000000000"` means `1.0`
- Timestamps are Unix seconds stored as strings
- Addresses and hashes are lowercase hex strings in stored data

## Core Entities

### Deposit

- Maker liquidity
- ID format: `{escrowAddress}_{depositId}`

```graphql
{
  Deposit(
    where: {
      status: { _eq: "ACTIVE" }
      acceptingIntents: { _eq: true }
    }
    order_by: { remainingDeposits: desc }
    limit: 10
  ) {
    id
    depositId
    depositor
    token
    remainingDeposits
    outstandingIntentAmount
    totalAmountTaken
    totalWithdrawn
    intentAmountMin
    intentAmountMax
    acceptingIntents
    status
    successRateBps
    totalIntents
    fulfilledIntents
    prunedIntents
    timestamp
    updatedAt
  }
}
```

### Intent

- Taker purchase
- ID format: `{chainId}_{intentHash}`
- Typical lifecycle: `SIGNALED -> FULFILLED | PRUNED | MANUALLY_RELEASED`

```graphql
{
  Intent(
    where: { status: { _eq: "SIGNALED" } }
    order_by: { signalTimestamp: desc }
    limit: 10
  ) {
    id
    intentHash
    depositId
    owner
    toAddress
    amount
    fiatCurrency
    conversionRate
    status
    isExpired
    expiryTime
    signalTimestamp
    signalTxHash
    fulfillTimestamp
    fulfillTxHash
    releasedAmount
    takerAmountNetFees
    paymentAmount
    paymentCurrency
    paymentId
  }
}
```

### QuoteCandidate

- Denormalized quoting view
- ID format: `{escrow}_{depositId}_{methodHash}_{currencyCode}`

```graphql
{
  QuoteCandidate(
    where: {
      isActive: { _eq: true }
      hasMinLiquidity: { _eq: true }
      currencyCode: { _eq: "0xc4ae21aac0c6549d71dd96035b7e0bdb6c79ebdba8891b666115bc976d16a29e" }
    }
    order_by: [{ takerConversionRate: asc }]
    limit: 20
  ) {
    id
    depositId
    depositor
    paymentMethodHash
    currencyCode
    conversionRate
    takerConversionRate
    managerFee
    availableTokenAmount
    maxTokenAvailablePerIntent
    maxFiatAvailablePerIntent
    maxQuoteableFiat
    intentAmountMin
    intentAmountMax
    successRateBps
    isActive
    hasMinLiquidity
  }
}
```

### MakerStats

- Aggregate row per maker
- ID format: `{chainId}_{makerAddress}`

```graphql
{
  MakerStats(order_by: { totalAmountTaken: desc }, limit: 10) {
    id
    maker
    totalAmountTaken
    grossDeposited
    totalWithdrawn
    outstandingIntentAmount
    activeDepositCount
    totalDepositCount
    fulfilledIntents
    prunedIntents
    totalIntents
    successRateBps
    realizedProfitUsdCents
    firstSeenAt
    updatedAt
  }
}
```

### TakerStats

- Aggregate row per taker
- ID format: `{chainId}_{ownerAddress}`

```graphql
{
  TakerStats_by_pk(id: "8453_0xabcdef...") {
    id
    owner
    lifetimeSignaledCount
    lifetimeFulfilledCount
    lifetimePruneCount
    lifetimeManualReleaseCount
    totalCancelledVolume
    totalFulfilledVolume
    lockScore
    lastIntentAt
    lastFulfilledAt
    firstSeenAt
  }
}
```

### RateManager

- Delegated rate manager
- ID format: `{chainId}_{rateManagerAddress}_{rateManagerId}`

```graphql
{
  RateManager(limit: 10) {
    id
    manager
    feeRecipient
    fee
    maxFee
    minLiquidity
    name
    uri
  }
}
```

### ManagerAggregateStats

```graphql
{
  ManagerAggregateStats(order_by: { totalFilledVolume: desc }) {
    id
    manager
    totalFilledVolume
    totalFeeAmount
    totalPnlUsdCents
    fulfilledIntents
    currentDelegatedBalance
    currentDelegatedDeposits
  }
}
```

## Common Query Recipes

### Specific deposit by on-chain ID

```graphql
query GetDeposit($escrow: String!, $depositId: String!) {
  Deposit(
    where: {
      escrowAddress: { _ilike: $escrow }
      depositId: { _eq: $depositId }
    }
  ) {
    id
    depositor
    remainingDeposits
    outstandingIntentAmount
    status
    acceptingIntents
    successRateBps
  }
}
```

Example variables:

```json
{
  "escrow": "0x777777779d229cdF3110e9de47943791c26300Ef",
  "depositId": "42"
}
```

### Intents for a taker address

```graphql
query TakerIntents($owner: String!) {
  Intent(
    where: { owner: { _ilike: $owner } }
    order_by: { signalTimestamp: desc }
    limit: 50
  ) {
    id
    status
    amount
    fiatCurrency
    conversionRate
    signalTimestamp
    fulfillTimestamp
    releasedAmount
    paymentAmount
  }
}
```

### Deposits for a maker address

```graphql
query MakerDeposits($depositor: String!) {
  Deposit(
    where: { depositor: { _ilike: $depositor } }
    order_by: { remainingDeposits: desc }
  ) {
    id
    depositId
    remainingDeposits
    outstandingIntentAmount
    totalAmountTaken
    status
    acceptingIntents
    totalIntents
    fulfilledIntents
    prunedIntents
    successRateBps
  }
}
```

### Protocol-wide summary

Fetch `MakerStats` rows and sum them client-side:

```graphql
{
  MakerStats(order_by: { id: asc }) {
    totalAmountTaken
    grossDeposited
    realizedProfitUsdCents
    successRateBps
  }
}
```

### Recent fulfilled intents

```graphql
{
  Intent(
    where: { status: { _eq: "FULFILLED" } }
    order_by: { fulfillTimestamp: desc }
    limit: 20
  ) {
    id
    owner
    amount
    fiatCurrency
    releasedAmount
    takerAmountNetFees
    paymentAmount
    paymentCurrency
    paymentId
    fulfillTimestamp
    fulfillTxHash
    conversionRate
  }
}
```

### Maker detail with platform breakdown

```graphql
query MakerDetail($makerId: String!, $makerPrefix: String!) {
  maker: MakerStats_by_pk(id: $makerId) {
    id
    maker
    totalAmountTaken
    grossDeposited
    fulfilledIntents
    prunedIntents
    successRateBps
    realizedProfitUsdCents
    firstSeenAt
  }
  platformStats: MakerPlatformStats(
    where: { id: { _like: $makerPrefix } }
    order_by: { totalAmountTaken: desc }
  ) {
    id
    paymentMethodHash
    totalAmountTaken
    fulfilledIntents
    prunedIntents
    realizedProfitUsdCents
  }
}
```

### Deposit history

```graphql
query DepositHistory($depositId: String!) {
  DepositDailySnapshot(
    where: { depositId: { _eq: $depositId } }
    order_by: { dayTimestamp: desc }
    limit: 30
  ) {
    dayTimestamp
    remainingDeposits
    outstandingIntentAmount
    dailyVolume
    dailyPnlUsdCents
    cumulativeVolume
    cumulativePnlUsdCents
    fulfilledIntents
    successRateBps
  }
}
```

## Relationship Map

```text
Deposit (1)--(N) DepositPaymentMethod
   |                    |
   +--(N) MethodCurrency+  (1 per deposit x method x currency)
   |         \- rates: conversionRate, takerConversionRate, managerFee
   |
   +--(N) Intent
   +--(N) DepositFundActivity
   \--(N) DepositDailySnapshot

QuoteCandidate = denormalized Deposit + MethodCurrency + DepositPaymentMethod

MakerStats <- aggregated from Deposits + Intents
TakerStats <- aggregated from Intents

RateManager (1)--(N) RateManagerRate
     +--(N) ManagerStats
     +--(1) ManagerAggregateStats
     \--(N) ManagerDailySnapshot
```
