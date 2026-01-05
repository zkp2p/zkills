---
name: create-zkp2p-provider
description: Create or update ZKP2P provider templates (zkTLS/Reclaim) by capturing target-platform network requests, mapping user-specified proof fields (identity, account attributes, or transactions), and producing the JSON provider template. Use when asked to create a ZKP2P provider template, analyze network logs, or translate API responses into template selectors.
---

# Create ZKP2P Provider

## Overview
Guide users to turn target-platform network requests into a valid ZKP2P provider JSON template with safe redaction and testable extraction rules.

## Skill installation and setup (Chrome DevTools MCP)
- Required before first use. Do not attempt capture until the user confirms it is installed.
- Install Chrome DevTools MCP in Claude Code: `claude mcp add chrome-devtools npx chrome-devtools-mcp@latest`.
- If any MCP call fails because Chrome DevTools MCP is not connected, pause and have the user install it first, then retry.

## Workflow

### 0) If Chrome DevTools MCP is not connected, set it up first
- If any MCP call fails because Chrome DevTools MCP is not connected, pause the workflow and instruct the user to install it using the Skill installation and setup section.
- Resume only after the user confirms installation.

### 1. Provider intake (first step)
- Ask the user to describe the provider they want to build and the general goal.
- Ask which website/platform (and region, if relevant) they are integrating.
- Ask if they already know where the data appears (list UI, detail page, profile/settings).
- Keep intake lightweight; you can refine specifics after capture.

Use this intake prompt (send to the user):
```
Tell me what provider you want to build and which platform/region (if relevant). If you already know where the data appears (list, detail, profile/settings), mention it; we can refine details after capture.
```

### 2. Required setup (login and context)
- Confirm Chrome DevTools MCP is installed (see Skill installation and setup section).
- Ask the user to log in and navigate to the relevant pages; capture requests as they browse.
- If the platform or flow is not yet known, ask them to show where the data appears; once they provide enough detail, start intercepting network requests.

Use this setup prompt (send to the user):
```
Before we continue, confirm Chrome DevTools MCP is installed (see Skill installation and setup section). Then log in to the platform and start navigating to the page with the data; I'll begin intercepting requests as you browse.
```

### 3. Capture request(s)
- Ask for captured network requests from the MCP session. If not available, direct them to `references/network-capture.md` and request a sanitized capture.
- Request at least one request/response that includes the required proof fields.
- **Check if multiple requests are needed** (see "Handling Multiple Data Sources" below).

### 4. Identify candidate request(s)
- Prefer the endpoint that returns the required proof fields (list, detail, profile, or settings).
- Verify response type (JSON vs HTML) to choose JSONPath vs XPath extraction.
 - For payment platforms, check platform docs (and unofficial API references) to discover API domains/endpoints to watch for in capture. Example: Monzo uses `api.monzo`, called with the UI session cookie.

### 5. Clarify endpoints and exploration
- Ask if there are other pages or endpoints worth exploring before locking on the request.
- If this is a payment/transaction proof, prompt the user to open a transaction list/history and then a specific transaction detail.
- Capture both list and detail endpoints; the list metadata URL can differ from the proof endpoint for a specific transaction (e.g., Wise).

Use this clarification prompt (send to the user):
```
Are there other pages or tabs we should explore before we lock onto an endpoint? If this is a payment proof, please open a transaction list/history and then click a specific transaction so we can capture both list and detail requests.
```

### 6. Map fields to selectors
- Define `paramNames` and `paramSelectors` for dynamic parameters used in `url`/`body`.
- Define `responseMatches` to validate proof fields.
- If the flow requires a list UI for user selection, define `transactionsExtraction` selectors; otherwise confirm whether it can be omitted.
- Flag sensitive headers and add `responseRedactions`.
- For fields from multiple sources, use appropriate `paramSelectors.source` values.

### 7. Assemble the template
- Fill required top-level fields (`actionType`, `proofEngine`, `authLink`, `url`, `method`, `metadata`).
- Set `actionType` to reflect the use case (identity, account, transaction).
- Set `proofEngine` to `"reclaim"` for new templates.
- Use `references/provider-template.md` for a skeleton and `references/provider-fields.md` for deep field guidance.
- When possible, align choices with patterns in `references/provider-examples.md` (especially for payment/transaction templates).
- For multi-request flows, configure `additionalProofs` or `metadataUrl`.

### 8. Test in the developer portal
- Assumes the user has already cloned the providers repo locally.
- Have the user test on `https://developer.zkp2p.xyz`.
- Ask them to install the PeerAuth extension: `https://chromewebstore.google.com/detail/peerauth-authenticate-and/ijpgccednehjpeclfcllnjjcmiohdjih`.
- In the developer settings dropdown, set the Providers URL to `http://localhost:8080`.

### 9. Validate and iterate
- Use Chrome DevTools MCP to open a fresh browser window/session, have the user log in, and re-run the flow to confirm the endpoint is captured.
- Test in the providers dev flow (see docs in `references/provider-template.md`).
- If replay fails due to CSRF/nonce tokens, have the user re-run the action in the page and re-capture the request (avoid manual replay of stale requests).
- Tighten `urlRegex`, add `fallbackUrlRegex`, and refine selectors based on failures.

---

## MCP-assisted capture (Chrome DevTools) — required

Chrome DevTools MCP must be installed before capture (see Skill installation and setup section). Use it to capture network requests directly (see `references/network-capture.md`).

Use an interactive flow:
- Ask for permission to control a Chrome session and access network data.
- Ask the user to log in to the target platform in the opened browser (if the platform/flow is not yet known, ask them to show where the data lives before intercepting).
- After login, tell the user to start browsing and navigate to the page that contains the proof fields.
- Ask: "Which page should I click to reach the relevant data (profile, settings, history, transactions)?" and follow their suggested path.
- Ask: "Are there other pages or tabs I should click to reveal the required fields?"
- Navigate the flow and trigger the relevant requests.
- Use `list_network_requests` to locate candidate requests and `get_network_request` (by `reqid`) to retrieve details.
- If response bodies are missing or obfuscated, ask for an alternate request or a different page to click.

---

## Handling Multiple Data Sources

Sometimes the required proof fields are not all in a single API response. Common scenarios:

### Scenario: Status or verification from a different endpoint
- The main response shows basic info (username, account ID, or transaction summary)
- Verification status or completion state requires a detail endpoint
- **Solution:** Use `metadataUrl` to fetch the detail endpoint, or configure `additionalProofs` for a second verification request.

### Scenario: Identity fields from separate API call
- One endpoint returns an account ID
- Another endpoint returns user profile info (username, display name)
- **Solution:**
  - Use `paramSelectors` with different `source` values to extract from multiple places
  - Consider if `userInput` click flow can trigger both requests
  - May need `additionalProofs` if both responses must be proven

### Scenario: Attribute in a different response than the main object
- The primary response contains the base object
- A related attribute lives in settings or headers
- **Solution:** Use `paramSelectors` with `source: "responseHeaders"` or configure `proofMetadataSelectors` to pull from the appropriate location.

### Scenario: Confirmation page after list view
- User must click an item to reveal the provable detail
- The detail request is what contains the verifiable data
- **Solution:** Configure `metadata.userInput` with `promptText` and `transactionXpath` to guide the click, then capture the triggered request.

### What to ask the user
When you suspect multiple sources are needed, ask:
1. "Which exact fields must be proven, and where do they appear?"
2. "Does clicking an item load additional details? If so, capture that request too."
3. "Is status/verification shown somewhere else? Which request contains it?"
4. "Capture 2-3 different requests if you're unsure which has all the fields."

### Template fields for multi-source extraction

```json
{
  "paramSelectors": [
    {"type": "jsonPath", "value": "$.user.id", "source": "responseBody"},
    {"type": "jsonPath", "value": "$.user.username", "source": "responseBody"}
  ],
  "metadata": {
    "metadataUrl": "https://api.example.com/user/{{USER_ID}}",
    "metadataUrlMethod": "GET"
  },
  "additionalProofs": [
    {
      "url": "https://api.example.com/verification/{{USER_ID}}",
      "method": "GET",
      "responseMatches": [{"type": "jsonPath", "value": "$.status"}]
    }
  ]
}
```

---

## Gotchas and troubleshooting
- Some endpoints require CSRF/one-time tokens; always re-trigger the request in-page to refresh tokens before capture.
- Transaction list metadata and transaction detail proof endpoints can differ; capture both.
- If response bodies are missing/obfuscated, try a different request or navigate to another page that loads the same data.
- HTML responses require XPath selectors; JSON responses use JSONPath.

## Output expectations
- Default to producing a JSON template file (ask for `{platform}/{provider}.json` name if not provided).
- For payment/transaction providers, default to `{platform}/transfer_platform.json`.
- Provide a short mapping table: source field -> JSONPath/XPath/regex.
- Call out missing data in the capture and ask for additional requests.
- Note any fields that require multi-source extraction.
- Confirm the intended proof statement and required fields with the user.

## References
- `references/network-capture.md` for request collection and redaction guidance.
- `references/provider-template.md` for the skeleton and extraction patterns.
- `references/provider-fields.md` for detailed field-by-field guidance from the docs.
- `references/provider-examples.md` for real templates from the providers repo.
- `references/extension-template-parsing.md` for exact extension parsing logic.
