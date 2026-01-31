# ZKP2P Indexer GraphQL Schema

## Query Types

### Intent
Primary entity for payment intents.

```graphql
type Intent {
  id: String!                    # Format: {chainId}_{intentHash}
  intentHash: String!            # The intent hash (primary lookup key)
  depositId: String!             # Associated deposit ID

  # Status
  status: IntentStatus!          # SIGNALED, FULFILLED, MANUALLY_RELEASED, PRUNED
  isExpired: Boolean!            # Whether intent has expired

  # Amounts
  amount: Numeric!               # Token amount in base units (6 decimals for USDC)
  paymentAmount: Numeric         # Fiat payment amount (cents)
  conversionRate: Numeric!       # Exchange rate used

  # Currency & Payment
  fiatCurrency: String!          # Currency hash
  paymentCurrency: String        # Payment currency
  paymentId: String              # Payment identifier
  paymentMethodHash: String      # Payment method hash
  paymentTimestamp: Numeric      # When payment was made

  # Addresses
  owner: String!                 # Intent owner (relayer)
  toAddress: String!             # Recipient address
  verifier: String!              # Verifier contract address
  orchestratorAddress: String!   # Orchestrator contract

  # Timestamps
  expiryTime: Numeric!           # When intent expires
  signalTimestamp: Numeric!      # When intent was signaled
  fulfillTimestamp: Numeric      # When fulfilled (if applicable)
  pruneTimestamp: Numeric        # When pruned (if applicable)
  updatedAt: Numeric!            # Last update timestamp

  # Transaction Hashes
  signalTxHash: String!          # Signal transaction
  fulfillTxHash: String          # Fulfill transaction (if fulfilled)
  pruneTxHash: String            # Prune transaction (if pruned)

  # Fees
  releasedAmount: Numeric        # Amount released after fees
  takerAmountNetFees: Numeric    # Taker amount after fees
}
```

### Deposit
LP deposit (liquidity pool).

```graphql
type Deposit {
  id: String!                      # Unique deposit ID
  depositId: Numeric!              # On-chain deposit ID
  chainId: Int!                    # Chain ID (8453 for Base)

  # Depositor Info
  depositor: String!               # LP address
  delegate: String!                # Delegate address

  # Status
  status: DepositStatus!           # ACTIVE, CLOSED, etc.
  acceptingIntents: Boolean!       # Whether accepting new intents

  # Amounts
  remainingDeposits: Numeric!      # Available liquidity
  outstandingIntentAmount: Numeric! # Locked in active intents
  totalAmountTaken: Numeric!       # Total amount fulfilled
  totalWithdrawn: Numeric!         # Total withdrawn by LP

  # Limits
  intentAmountMin: Numeric!        # Minimum intent amount
  intentAmountMax: Numeric!        # Maximum intent amount

  # Stats
  totalIntents: Int!               # Total intent count
  fulfilledIntents: Int!           # Fulfilled count
  signaledIntents: Int!            # Signaled count
  prunedIntents: Int!              # Pruned count
  successRateBps: Int!             # Success rate (basis points)

  # Token
  token: String!                   # Token contract address
  escrowAddress: String!           # Escrow contract address

  # Timestamps
  timestamp: Numeric!              # Deposit creation time
  blockNumber: Numeric!            # Block number
  txHash: String!                  # Transaction hash
  updatedAt: Numeric!              # Last update

  # Relationships
  currencies: [MethodCurrency!]!   # Supported currencies
  paymentMethods: [DepositPaymentMethod!]! # Payment methods
  intents: [Intent!]!              # Associated intents
}
```

### DepositPaymentMethod
Payment methods supported by a deposit.

```graphql
type DepositPaymentMethod {
  id: String!
  depositId: String!
  paymentMethodHash: String!
  conversionRate: Numeric!
  minConversionRate: Numeric!
  isActive: Boolean!
  createdAt: Numeric!
  updatedAt: Numeric!
}
```

### MakerStats
Aggregated statistics for LPs.

```graphql
type MakerStats {
  id: String!                    # LP address
  totalDeposits: Numeric!        # Total deposited
  currentDeposits: Numeric!      # Current balance
  totalIntents: Int!             # Total intents
  fulfilledIntents: Int!         # Fulfilled count
  prunedIntents: Int!            # Pruned count
  successRateBps: Int!           # Success rate
  totalProfit: Numeric!          # Total profit
  updatedAt: Numeric!
}
```

### TakerStats
Aggregated statistics for takers.

```graphql
type TakerStats {
  id: String!                    # Taker address
  totalIntents: Int!             # Total intents
  fulfilledIntents: Int!         # Fulfilled count
  prunedIntents: Int!            # Pruned count
  totalVolume: Numeric!          # Total volume
  updatedAt: Numeric!
}
```

## Event Types

### Orchestrator Events

```graphql
type Orchestrator_V21_IntentSignaled {
  id: String!
  intentHash: String!
  depositId: Numeric!
  owner: String!
  to: String!
  amount: Numeric!
  conversionRate: Numeric!
  expiryTime: Numeric!
  fiatCurrency: String!
  verifier: String!
  transactionHash: String!
  blockNumber: Int!
  timestamp: Numeric!
}

type Orchestrator_V21_IntentFulfilled {
  id: String!
  intentHash: String!
  paymentId: String!
  paymentCurrency: String!
  paymentAmount: Numeric!
  releasedAmount: Numeric!
  transactionHash: String!
  blockNumber: Int!
  timestamp: Numeric!
}

type Orchestrator_V21_IntentPruned {
  id: String!
  intentHash: String!
  depositId: Numeric!
  transactionHash: String!
  blockNumber: Int!
  timestamp: Numeric!
}
```

### Escrow Events

```graphql
type Escrow_V21_DepositReceived {
  id: String!
  depositId: Numeric!
  depositor: String!
  token: String!
  amount: Numeric!
  transactionHash: String!
  timestamp: Numeric!
}

type Escrow_V21_FundsUnlockedAndTransferred {
  id: String!
  intentHash: String!
  depositId: Numeric!
  amount: Numeric!
  to: String!
  transactionHash: String!
  timestamp: Numeric!
}
```

## Filtering and Ordering

All list queries support:

```graphql
# Filtering
where: {
  field: {_eq: value}           # Equals
  field: {_neq: value}          # Not equals
  field: {_gt: value}           # Greater than
  field: {_gte: value}          # Greater than or equal
  field: {_lt: value}           # Less than
  field: {_lte: value}          # Less than or equal
  field: {_in: [values]}        # In array
  field: {_is_null: boolean}    # Is null
  _and: [{...}, {...}]          # AND conditions
  _or: [{...}, {...}]           # OR conditions
}

# Ordering
order_by: {field: asc}          # Ascending
order_by: {field: desc}         # Descending
order_by: [{field1: asc}, {field2: desc}]  # Multiple

# Pagination
limit: 10
offset: 20
```

## Notes

- All amounts are in base units (USDC = 6 decimals, so 1000000 = $1)
- Timestamps are Unix epoch seconds
- Chain ID 8453 = Base mainnet
- Intent IDs are formatted as `{chainId}_{intentHash}`
