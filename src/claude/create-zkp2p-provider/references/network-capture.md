# Network Request Capture Guide

## Goal
Capture request/response pairs that include the required proof fields (identity, account attributes, or transaction data). Sometimes you'll need multiple requests if fields are spread across different endpoints.

---

## Start small, then scale
Do not try to capture everything at once. Work incrementally:
1. Capture one request and confirm it includes the fields you need.
2. Inspect one response and identify the exact field paths.
3. Only then capture additional requests (list + detail, status endpoints, etc).

## Chrome DevTools MCP (live capture via MCP tools)

Use Chrome DevTools MCP to capture network requests directly from a live Chrome session without installing PeerAuth.

1. Ensure Chrome DevTools MCP is installed and configured for your MCP client.
   - Repo: https://github.com/ChromeDevTools/chrome-devtools-mcp
   - Follow the platform-specific install steps in the skill instructions.
2. Start Chrome (or let MCP start it), then log in to the target site.
   - If your login only works in your existing Chrome profile, connect MCP to a running Chrome instance via remote debugging (see the repo for `--browser-url` or `--autoConnect`).
3. After login, tell the user to start browsing and navigate to the page that contains the proof fields.
   - Prompt for suggested pages or tabs they can click to reach profile, settings, history, or transaction views.
4. Perform the flow so the relevant network calls appear.
5. Use MCP network tools to capture the request(s):
   - `list_network_requests` to find candidate requests (use `includePreservedRequests: true` if needed).
   - `get_network_request` with the request `reqid` to fetch full details.
6. Share the request/response details (with redaction per the section below).

Note: The MCP server can see everything in the browser session. Avoid exposing sensitive data you cannot share.

---

## Capturing Multiple Requests

Often, not all required fields are in a single response. You may need to capture multiple requests:

### When to capture multiple requests
- **List + detail**: List shows basic info, clicking loads full details
- **Status from different endpoint**: Verification/completion status is a separate call
- **Identity info separate**: Username or display name comes from a profile API
- **Settings separate**: Attributes live in settings, not the primary response

### How to identify if you need multiple requests
1. Look at the page: Can you see all required fields?
2. Click an item: Does it load new data? Check the Network tab for new requests.
3. Compare: Does the list response have the same fields as the detail response?

### What to capture for multi-request scenarios
1. **Primary request**: The main endpoint containing most required fields
2. **Secondary request(s)**: Any additional calls that contain missing fields
3. Note which fields come from which request

Example notes to provide:
```
Request 1 (profile):
- URL: /api/profile
- Contains: username, account_id

Request 2 (verification - triggered on click):
- URL: /api/verification/{id}
- Contains: status, verified_at
```

---

## Minimum fields to capture

For each request, capture:
- Request URL and method
- Request headers (redact sensitive values)
- Request body (if POST/PUT)
- Response status code
- Response body

Note which proof fields map to the requests. Examples:
| Field | Required? | Notes |
|-------|-----------|-------|
| username | Yes | Account handle |
| accountId | Yes | Internal account ID |
| status | Optional | verified/pending |
| amount | Optional | Only if proving a transaction |
| date | Optional | Only if proving a transaction |

Payment platforms: require only recipient ID, amount, timestamp, and status (reversible vs settled); include currency if multi-currency. Ask if recipient IDs appear in multiple places and whether amount is split into cents/dollars.

---

## Redaction guidance

Before sharing, redact sensitive information:

| Keep | Redact |
|------|--------|
| URL structure and path | Account numbers, user IDs → REDACTED |
| Header names | Cookie values, session tokens → REDACTED |
| Response field names | Access tokens, API keys → REDACTED |
| Response structure | Personal email, phone → REDACTED |
| Proof values | Full names unless required for proof |

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
  "profile": {
    "id": "user_123",
    "username": "jane_doe",
    "status": "verified"
  }
}
```

```
Field      | Source   | Path/Selector
-----------|----------|---------------------------
username   | Request 1| $.profile.username
accountId  | Request 1| $.profile.id
status     | Request 1| $.profile.status
```

This allows template construction without exposing sensitive data.
