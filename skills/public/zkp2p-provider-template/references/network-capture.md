# Network Request Capture (HAR or Intercepted Requests)

## Goal
Capture a request/response pair that includes transaction data (amount, date/timestamp, recipient ID/name, and ideally status/currency).

## Option A: Browser DevTools (HAR export)
1. Open the payment site and log in.
2. Open DevTools (F12) and click the Network tab.
3. Enable Preserve log and Disable cache.
4. Filter to XHR/Fetch requests.
5. Navigate to the transactions page and open or click a specific transaction.
6. Identify the request whose response contains transaction data.
7. Right-click the Network list and choose "Save all as HAR with content" (or "Copy all as HAR").
8. Share the HAR file or a sanitized excerpt (see Redaction).

## Option B: PeerAuth extension (Intercepted Requests)
1. Open the ZKP2P sidebar and enable Intercepted Requests.
2. Repeat the transaction flow until you see the request that contains transaction data.
3. Export or copy the intercepted request details.

## Minimum fields to share
- Request URL and method
- Request headers (redact sensitive values)
- Request body (if any)
- Response status
- Response body containing transaction data
- Notes on which fields map to: amount, date/timestamp, recipient ID/name, status, currency

## Redaction guidance
- Replace secrets in headers or cookies with "REDACTED".
- Remove or mask access tokens, session IDs, and account numbers.
- Keep enough structure so JSONPath/XPath/regex selectors still work.

## If you cannot share raw traffic
Provide a small, representative JSON or HTML response sample and a mapping table:
- amount -> $.path.to.amount
- date -> $.path.to.date
- recipient -> $.path.to.recipient
- status -> $.path.to.status (if available)
- currency -> $.path.to.currency (if available)
