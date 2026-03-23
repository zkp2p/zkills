# Network Request Capture Guide

## Goal
Capture request/response pairs that include the required proof fields (identity, account attributes, or transaction data). Sometimes you will need multiple requests because the list UI and the final proof do not come from the same endpoint.

## Preferred capture path
- Prefer Chrome DevTools MCP over Playwright or custom browser automation.
- Use manual sanitized captures only when MCP is unavailable, the user already has them, or the user explicitly wants a manual path.
- Do not capture everything at once. Start with one request, confirm the fields, then expand only if needed.

## Chrome DevTools MCP workflow

Use the same interaction pattern as the `chrome-devtools` skill:
1. Ensure Chrome DevTools MCP is installed and connected for your client.
2. Open or attach to Chrome, then ask the user to log in.
3. Use `wait_for` and `take_snapshot` to understand the page before clicking.
4. Ask the user to open the page that visibly contains the target data.
5. Trigger the list and detail views that load the relevant requests.
6. Use `list_network_requests` to locate candidate requests.
   - Use preserved requests if the flow navigates across pages.
   - Narrow the list to the small set of likely `fetch`, `xhr`, or document requests.
7. Use `get_network_request` on the relevant request ids to pull full details.
8. Redact secrets before sharing or storing any sample.

Notes:
- Prefer `take_snapshot` over screenshots for navigation and page-state inspection.
- Re-trigger the action if the captured request contains one-time headers, CSRF tokens, or empty bodies.
- If the login only works in an existing Chrome profile, connect MCP to that running instance instead of recreating the flow elsewhere.
- The MCP server can see the whole browser session. Keep the captured material to the minimum needed for the template.

## Capturing multiple requests

Often, not all required fields are in a single response. You may need to capture multiple requests.

### When to capture multiple requests
- List + detail: the list shows basic info, but clicking loads the real proof data.
- Status from a different endpoint: verification or settlement state is separate.
- Identity info separate: username or display name comes from profile/settings APIs.
- Settings separate: account attributes live outside the primary transaction response.

### How to identify whether you need more than one request
1. Look at the page. Can you already see every field that must be proven?
2. Click a row or tab. Does a new network request appear?
3. Compare list and detail responses. Which one contains the stable proof fields?
4. Decide whether the second request belongs in `metadataUrl` or `additionalProofs`.

### What to capture for multi-request scenarios
1. Primary request: the main endpoint containing most required fields.
2. Secondary request(s): any additional calls that contain missing fields.
3. Notes on which fields come from which request.

Example notes:
````
Request 1 (list):
- URL: /api/transfers?page=0&size=10
- Contains: amount, paymentId, date

Request 2 (detail):
- URL: /api/transfers/{id}
- Contains: recipientId, status
````

## Minimum fields to capture

For each request, capture:
- Request URL and method
- Request headers (redact sensitive values)
- Request body (if POST, PUT, or PATCH)
- Response status code
- Response body

Also record:
- Whether the response is JSON or HTML
- Whether the list response already contains stable `paymentId` values
- Whether the request must be replayed in-page
- Whether a second proof is required for recipient identity or settlement details

Common proof-field checklist:

| Field | Required? | Notes |
|-------|-----------|-------|
| recipientId | Usually | Prefer a stable recipient identifier |
| amount | Usually | Note whether it is minor or major units |
| timestamp/date | Usually | Capture the raw response value |
| status | Often | Especially for reversible vs settled flows |
| currency | Conditional | Include it when the platform supports multiple currencies |
| paymentId | Usually | Needed for selection and detail replay |

## Redaction guidance

Before sharing, redact sensitive information.

| Keep | Redact |
|------|--------|
| URL structure and path | Account numbers, user IDs -> `REDACTED` |
| Header names | Cookie values, session tokens -> `REDACTED` |
| Response field names | Access tokens, API keys -> `REDACTED` |
| Response structure | Personal email, phone -> `REDACTED` |
| Proof values | Full names unless required for the proof |

Example:
````
Authorization: Bearer REDACTED
Cookie: session=REDACTED; csrf=REDACTED
````

Keep enough structure for JSONPath, XPath, or regex selectors to work.
If the final artifact is going into this public repo, keep only public-safe interface details. Do not include private repo links, internal-only endpoints, or raw sensitive payloads.

## If you cannot share raw traffic

Provide a representative sample plus a mapping table.

```json
{
  "profile": {
    "id": "user_123",
    "username": "jane_doe",
    "status": "verified"
  }
}
```

````
Field       | Source     | Path/Selector
------------|------------|---------------------------
username    | Request 1  | $.profile.username
accountId   | Request 1  | $.profile.id
status      | Request 1  | $.profile.status
````

This is enough to author a template without exposing live secrets.

## Capture checklist

- Can the selection UI be built from a list endpoint alone?
- If not, which click triggers the detail request?
- Which values belong in `transactionsExtraction` versus `responseMatches`?
- Which headers must remain secret?
- Does the current flow need `metadataUrl`, `additionalProofs`, or neither?
- Would Chrome DevTools MCP be enough for the next iteration, or is the user already providing sanitized payloads?
