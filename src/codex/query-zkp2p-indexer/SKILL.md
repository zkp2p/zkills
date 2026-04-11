---
name: query-zkp2p-indexer
description: Query the ZKP2P Hasura GraphQL indexer for deposits, intents, quote candidates, maker and taker stats, manager stats, and related Base escrow activity. Use when the user asks for ZKP2P protocol data, wants help writing indexer queries, or needs bigint and hash fields formatted into human-readable values.
metadata:
  short-description: Query and format ZKP2P indexer data
---

# Query ZKP2P Indexer

Use this skill when the user needs protocol data from the ZKP2P on-chain indexer on Base (`chainId = 8453`).

## Endpoints

- Production default: `https://indexer.zkp2p.xyz/v1/graphql`
- Staging, only if requested: `https://indexer-staging.zkp2p.xyz/v1/graphql`
- Fixtures, only if explicitly requested and available: `https://indexer-staging.zkp2p.xyz/fixtures/v1/graphql`

Pass `x-api-key` when available for higher rate limits. Public access is rate-limited.

## Workflow

1. Identify the entity the user actually wants: `Deposit`, `Intent`, `QuoteCandidate`, `MakerStats`, `TakerStats`, `RateManager`, `ManagerAggregateStats`, or a snapshot table.
2. Write a parameterized Hasura-flavored GraphQL query. Prefer variables over hardcoded values.
3. Use `_ilike` for Ethereum addresses. Do not use `_eq` for addresses because checksum casing may differ.
4. Query with a JSON POST body shaped like `{"query":"...","variables":{...}}`.
5. Format bigint units before answering. Raw indexer fields are usually not human-readable.

## Querying

Use `curl` unless the task clearly benefits from another client:

```bash
curl -s -X POST https://indexer.zkp2p.xyz/v1/graphql \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ZKP2P_INDEXER_API_KEY" \
  -d '{"query":"query Example($owner: String!) { Intent(where: { owner: { _ilike: $owner } }, limit: 5) { id status amount signalTimestamp } }","variables":{"owner":"0xabc%"}}'
```

Omit the `x-api-key` header when no key is available.

## Hasura Reminders

- Pagination: `limit`, `offset`
- Ordering: `order_by: { field: asc }` or arrays such as `order_by: [{ field: desc }]`
- Primary key lookups: `Entity_by_pk(id: "...")`
- Common operators: `_eq`, `_in`, `_ilike`, `_gte`, `_lte`, `_gt`, `_lt`, `_like`
- Cross-row totals are often easiest to compute client-side after fetching rows

## Data Formatting

- USDC and token amounts: divide by `1e6`
- Conversion rates: divide by `1e18`
- Basis points: divide by `100` for percent
- Profit in cents: divide by `100`
- Payment amounts: divide by `100`
- Timestamps: `new Date(Number(timestamp) * 1000)`
- Addresses and hashes: show the raw value when precision matters; otherwise truncate for readability
- Link transactions and addresses to BaseScan when presenting them to the user

## References

- Read [references/query-patterns.md](references/query-patterns.md) for entity notes, example queries, and the relationship map.
- Read [references/lookups.md](references/lookups.md) for currency hashes, payment method hashes, and production contract addresses.

## Response Guidelines

- Prefer human-readable summaries over dumping raw GraphQL responses.
- Include the exact query you ran when the user is asking for a reusable query or debugging help.
- If a currency or payment method hash is unknown, report the raw hash and map it only when the lookup is explicit or the inference is clearly labeled as a guess.
