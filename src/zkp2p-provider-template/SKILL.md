---
name: zkp2p-provider-template
description: Guide users to build or update ZKP2P provider templates (zkTLS/Reclaim) by capturing payment-platform network requests, mapping transaction fields (amount, date, recipient, status/currency), and producing the JSON provider template. Use when asked to create a ZKP2P provider template, analyze HAR/network logs, or translate API responses into template fields.
---

# ZKP2P Provider Template

## Overview
Guide users to turn payment-platform network requests into a valid ZKP2P provider JSON template with safe redaction and testable extraction rules.

## Workflow

### 1. Intake and request capture
- Ask which platform, region, and transaction flow (send vs receive) they are integrating.
- Ask for captured network requests (HAR/export or PeerAuth intercepted requests). If not available, direct them to `references/network-capture.md` and request a sanitized capture.
- Request at least one request/response that includes amount, date/timestamp, recipient ID/name, and ideally status/currency.
- **Check if multiple requests are needed** (see "Handling Multiple Data Sources" below).

### 2. Identify candidate request(s)
- Prefer the endpoint that returns a transaction list or transaction detail payload.
- Verify response type (JSON vs HTML) to choose JSONPath vs XPath extraction.

### 3. Map fields to selectors
- Define `paramNames` and `paramSelectors` for dynamic parameters used in `url`/`body`.
- Define `transactionsExtraction` selectors and `responseMatches` to validate proof fields.
- Flag sensitive headers and add `responseRedactions`.
- For fields from multiple sources, use appropriate `paramSelectors.source` values.

### 4. Assemble the template
- Fill required top-level fields (`actionType`, `proofEngine`, `authLink`, `url`, `method`, `metadata`).
- Set `proofEngine` to `"reclaim"` for new templates.
- Use `references/provider-template.md` for a skeleton and `references/provider-fields.md` for deep field guidance.
- When possible, align choices with patterns in `references/provider-examples.md`.
- For multi-request flows, configure `additionalProofs` or `metadataUrl`.

### 5. Validate and iterate
- Test in the providers dev flow (see docs in `references/provider-template.md`).
- Tighten `urlRegex`, add `fallbackUrlRegex`, and refine selectors based on failures.

---

## Handling Multiple Data Sources

Sometimes the required transaction fields are not all in a single API response. Common scenarios:

### Scenario: Payment status from a different endpoint
- The transaction list shows basic info (amount, recipient, date)
- Payment completion status requires clicking into a detail view or calling a separate endpoint
- **Solution:** Use `metadataUrl` to fetch the detail endpoint, or configure `additionalProofs` for a second verification request.

### Scenario: Username/recipient from separate API call
- One endpoint returns transaction IDs and amounts
- Another endpoint returns user profile info (username, display name)
- **Solution:**
  - Use `paramSelectors` with different `source` values to extract from multiple places
  - Consider if `userInput` click flow can trigger both requests
  - May need `additionalProofs` if both responses must be proven

### Scenario: Currency in a different response than amount
- Amount is in the transaction object
- Currency code comes from account settings or a header
- **Solution:** Use `paramSelectors` with `source: "responseHeaders"` or configure `proofMetadataSelectors` to pull from the appropriate location.

### Scenario: Confirmation page after transaction list
- User must click a transaction to reveal the provable detail
- The detail request is what contains the verifiable data
- **Solution:** Configure `metadata.userInput` with `promptText` and `transactionXpath` to guide the click, then capture the triggered request.

### What to ask the user
When you suspect multiple sources are needed, ask:
1. "Does clicking a transaction load additional details? If so, capture that request too."
2. "Is the payment status (completed/pending) visible? Which request contains it?"
3. "Where does the username/recipient ID appear? Is it in the same response as the amount?"
4. "Capture 2-3 different requests if you're unsure which has all the fields."

### Template fields for multi-source extraction

```json
{
  "paramSelectors": [
    {"type": "jsonPath", "value": "$.amount", "source": "responseBody"},
    {"type": "jsonPath", "value": "$.user.id", "source": "responseBody"},
    {"type": "regex", "value": "currency=([A-Z]{3})", "source": "url"}
  ],
  "metadata": {
    "metadataUrl": "https://api.example.com/transaction/{{PAYMENT_ID}}",
    "metadataUrlMethod": "GET"
  },
  "additionalProofs": [
    {
      "url": "https://api.example.com/user/{{USER_ID}}",
      "method": "GET",
      "responseMatches": [{"type": "jsonPath", "value": "$.verified"}]
    }
  ]
}
```

---

## Output expectations
- Default to producing a JSON template file (ask for `{platform}/{provider}.json` name if not provided).
- Provide a short mapping table: source field -> JSONPath/XPath/regex.
- Call out missing data in the capture and ask for additional requests.
- Note any fields that require multi-source extraction.

## References
- `references/network-capture.md` for request collection and redaction guidance.
- `references/provider-template.md` for the skeleton and extraction patterns.
- `references/provider-fields.md` for detailed field-by-field guidance from the docs.
- `references/provider-examples.md` for real templates from the providers repo.
- `references/extension-template-parsing.md` for exact extension parsing logic.
