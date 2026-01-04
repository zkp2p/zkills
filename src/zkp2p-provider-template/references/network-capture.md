# Network Request Capture Guide

## Goal
Capture request/response pairs that include transaction data (amount, date/timestamp, recipient ID/name, and ideally status/currency). Sometimes you'll need multiple requests if fields are spread across different endpoints.

---

## Option A: Browser DevTools (HAR export)

1. Open the payment site and log in.
2. Open DevTools (F12) and click the **Network** tab.
3. Enable **Preserve log** and **Disable cache**.
4. Filter to **XHR/Fetch** requests.
5. Navigate to the transactions page and open or click a specific transaction.
6. Identify the request whose response contains transaction data.
7. Right-click the Network list and choose "Save all as HAR with content" (or "Copy all as HAR").
8. Share the HAR file or a sanitized excerpt (see Redaction section).

---

## Option B: PeerAuth Extension (Intercepted Requests)

1. Open the ZKP2P sidebar and enable Intercepted Requests.
2. Repeat the transaction flow until you see the request that contains transaction data.
3. Export or copy the intercepted request details.

---

## Capturing Multiple Requests

Often, not all required fields are in a single response. You may need to capture multiple requests:

### When to capture multiple requests
- **Transaction list + detail**: List shows basic info, clicking loads full details
- **Status from different endpoint**: Payment completion status is a separate call
- **User info separate**: Recipient username comes from a profile API
- **Currency/settings separate**: Currency code is in account settings, not transaction

### How to identify if you need multiple requests
1. Look at the page: Can you see all required fields (amount, date, recipient, status)?
2. Click a transaction: Does it load new data? Check Network tab for new requests.
3. Compare: Does the list response have the same fields as the detail response?

### What to capture for multi-request scenarios
1. **Primary request**: The main transaction list or detail endpoint
2. **Secondary request(s)**: Any additional calls that contain required fields
3. Note which fields come from which request

Example notes to provide:
```
Request 1 (transaction list):
- URL: /api/transactions
- Contains: amount, date, transaction_id

Request 2 (transaction detail - triggered on click):
- URL: /api/transactions/{id}
- Contains: status, recipient_username, currency
```

---

## Minimum fields to capture

For each request, capture:
- Request URL and method
- Request headers (redact sensitive values)
- Request body (if POST/PUT)
- Response status code
- Response body

Note which fields map to:
| Field | Required? | Notes |
|-------|-----------|-------|
| amount | Yes | Transaction value |
| date | Yes | Transaction timestamp |
| recipient | Yes | Username or ID of counterparty |
| paymentId | Yes | Unique transaction identifier |
| status | Recommended | completed/pending/failed |
| currency | Recommended | USD, EUR, etc. |

---

## Redaction guidance

Before sharing, redact sensitive information:

| Keep | Redact |
|------|--------|
| URL structure and path | Account numbers, user IDs → REDACTED |
| Header names | Cookie values, session tokens → REDACTED |
| Response field names | Access tokens, API keys → REDACTED |
| Transaction structure | Personal email, phone → REDACTED |
| Amount/date/status values | Full names (unless needed for recipient) |

Example:
```
Authorization: Bearer REDACTED
Cookie: session=REDACTED; csrf=REDACTED
```

Keep enough structure for JSONPath/XPath/regex selectors to work.

---

## If you cannot share raw traffic

Provide a representative sample and mapping table:

```json
{
  "transactions": [
    {
      "id": "txn_123",
      "amount": 50.00,
      "date": "2024-01-15T10:30:00Z",
      "counterparty": {"username": "john_doe"},
      "status": "completed"
    }
  ]
}
```

```
Field      | Source   | Path/Selector
-----------|----------|---------------------------
amount     | Request 1| $.transactions[*].amount
date       | Request 1| $.transactions[*].date
recipient  | Request 1| $.transactions[*].counterparty.username
paymentId  | Request 1| $.transactions[*].id
status     | Request 2| $.detail.status (from detail endpoint)
```

This allows template construction without exposing sensitive data.
