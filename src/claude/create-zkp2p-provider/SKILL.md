---
name: create-zkp2p-provider
description: Create or update ZKP2P provider templates (zkTLS/Reclaim) by capturing target-platform network requests, mapping user-specified proof fields (identity, account attributes, or transactions), and producing the JSON provider template. Use when asked to create a ZKP2P provider template, analyze network logs, or translate API responses into template selectors.
---

# Create ZKP2P Provider

## Overview
Guide users to turn target-platform network requests into a valid ZKP2P provider JSON template with safe redaction and testable extraction rules.

## Skill installation and setup (Chrome DevTools MCP)
- As part of installing this skill, install Chrome DevTools MCP in Claude Code: `claude mcp add chrome-devtools npx chrome-devtools-mcp@latest`.
- This is required to capture network requests.

## Workflow

### 1. Provider intake (first step)
- Ask the user to describe the provider they want to build.
- Ask which option applies: (1) payment/transaction provider or (2) something else (identity/account/other).
- Ask which website/platform and region they are integrating.
- Ask the use case and the exact proof fields required (e.g., identity/username, account status, account ID, transaction details).
- Ask what the proof should attest (example: "user owns Venmo @handle").
- Ask if the data appears in a list UI, a detail page, or a profile/settings page.
- If it's a payment transaction, the goal is to mirror the structure of reference transaction templates in `references/provider-examples.md`.

Use this intake prompt (send to the user):
```
Describe the provider you want to build. Is it (1) a payment/transaction provider or (2) something else (identity/account/other)? Which website/platform and region? What exact fields must be proven, and what should the proof attest? Where does the data appear (list, detail, profile/settings)?
```

### 2. Required setup (login and context)
- Confirm Chrome DevTools MCP is installed (see Skill installation and setup section).
- If the platform or flow is not yet known, ask the user to log in to the site and describe where the proof data appears; once they provide enough detail, start intercepting network requests.

Use this setup prompt (send to the user):
```
I need Chrome DevTools MCP to capture network requests. If it is not installed, install it using the Skill installation and setup section. Then log in to the platform and tell me which page shows the required data; once you're there, I'll begin intercepting requests.
```

### 3. Capture request(s)
- Ask for captured network requests from the MCP session. If not available, direct them to `references/network-capture.md` and request a sanitized capture.
- Request at least one request/response that includes the required proof fields.
- **Check if multiple requests are needed** (see "Handling Multiple Data Sources" below).

### 4. Identify candidate request(s)
- Prefer the endpoint that returns the required proof fields (list, detail, profile, or settings).
- Verify response type (JSON vs HTML) to choose JSONPath vs XPath extraction.

### 5. Map fields to selectors
- Define `paramNames` and `paramSelectors` for dynamic parameters used in `url`/`body`.
- Define `responseMatches` to validate proof fields.
- If the flow requires a list UI for user selection, define `transactionsExtraction` selectors; otherwise confirm whether it can be omitted.
- Flag sensitive headers and add `responseRedactions`.
- For fields from multiple sources, use appropriate `paramSelectors.source` values.

### 6. Assemble the template
- Fill required top-level fields (`actionType`, `proofEngine`, `authLink`, `url`, `method`, `metadata`).
- Set `actionType` to reflect the use case (identity, account, transaction).
- Set `proofEngine` to `"reclaim"` for new templates.
- Use `references/provider-template.md` for a skeleton and `references/provider-fields.md` for deep field guidance.
- When possible, align choices with patterns in `references/provider-examples.md` (especially for payment/transaction templates).
- For multi-request flows, configure `additionalProofs` or `metadataUrl`.

### 7. Validate and iterate
- Test in the providers dev flow (see docs in `references/provider-template.md`).
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

## Output expectations
- Default to producing a JSON template file (ask for `{platform}/{provider}.json` name if not provided).
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
