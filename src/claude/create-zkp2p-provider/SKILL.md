---
name: create-zkp2p-provider
description: Create or update ZKP2P provider templates (zkTLS/Reclaim) by capturing target-platform network requests, mapping user-specified proof fields (identity, account attributes, or transactions), and producing the JSON provider template. Use when asked to create a ZKP2P provider template, analyze network logs, or translate API responses into template selectors.
---

# Create ZKP2P Provider

## Overview
Guide users to turn target-platform network requests into a valid ZKP2P provider JSON template with safe redaction and testable extraction rules.

This repo is public. Author against the public provider interface only:
- Restate implementation findings as interface rules.
- Do not paste private repo links, internal file paths, secrets, raw cookies, or sensitive payloads into the skill output or PR.
- Prefer Chrome DevTools MCP for capture and debugging. Do not default to Playwright or custom browser automation from other repos unless the user explicitly asks for that path.

## Choosing your approach
- If the user already has network captures or API logs, skip MCP setup and request the payloads.
- If updating an existing provider, ask for the current template and target changes before capturing.
- If the user only wants guidance (not a template), focus on field mapping and redaction notes.

## Public interface constraints
- Provider files resolve at `{platform}/{actionType}.json`. Keep the folder name, `metadata.platform`, and `actionType` aligned with that path.
- If the provider will live in the public providers repo, its path must also be present in `providers.json`.
- Current mobile-specific fields live under `mobile.*` (`useExternalAction`, `external`, `internal`, `login`, `userAgent`, `additionalClientOptions`). Do not use older top-level shapes such as `additionalClientOptions` outside `mobile`.
- Extension-oriented compatibility fields such as `metadata.userInput` and `metadata.shouldSkipCloseTab` appear in current public templates, but they are not mobile-only requirements. Treat them as optional compatibility fields and verify them against the target runtime.
- Downstream client wrappers typically reference `authLink`, `actionPlatform`, `actionType`, `minExtensionVersion`, and `totalProofs`. The provider JSON is only one half of the integration.

## Key principles
1. Start with one request, confirm fields, then scale to additional endpoints.
2. Keep prompts short and sequential; ask 1-2 questions at a time.
3. Prefer stable identifiers and minimal responseMatches.
4. Re-trigger actions in the UI to avoid stale tokens or mismatches.
5. Prefer Chrome DevTools MCP over Playwright for capture and iteration.
6. Keep public artifacts focused on interface behavior, never private implementation details.

## Workflow loop (repeat as needed)
1. Capture -> inspect -> map -> assemble -> test -> refine.

## Skill installation and setup (Chrome DevTools MCP)
- Required before first use. Do not attempt capture until it is installed.
- If Chrome DevTools MCP is missing or MCP tools are unavailable, ask the user to install it in Claude Code: `claude mcp add chrome-devtools -- npx chrome-devtools-mcp@latest`.
- If the client does not expose the `chrome-devtools` skill or the `create-zkp2p-provider` skill, ask the user to install or enable the missing skill before continuing.
- Ask the user to open `chrome://inspect/#remote-debugging` in the Chrome profile they want to reuse and turn on remote debugging before live capture.
- Explain that this lets Chrome DevTools MCP attach to the user's existing Chrome session and reuse current cookies instead of opening a fresh browser like Playwright-style automation.
- If they just installed MCP or a missing skill, resume only after they restart Claude Code and confirm the restart.

## Workflow

### 0) If Chrome DevTools MCP is not connected, set it up first
- If any MCP call fails because Chrome DevTools MCP is not connected, ask the user to install it using the Skill installation and setup section.
- If the `chrome-devtools` skill or this skill is missing, ask the user to install the missing skill first.
- Resume only after the user confirms the install, the restart, and that remote debugging is enabled in the Chrome session they want to reuse.

### 1. Provider intake (first step)
- Take user input from the initial skill call and answer the following questions if already provided.
- If the user already shared captures or an existing template, acknowledge and skip ahead to the relevant step.
- Ask for permission to control a Chrome session and access network data with Chrome DevTools MCP.
- Ask which website/platform (and region only if it materially changes the flow) they are integrating, and where the data appears (list UI, detail page, profile/settings).
- If they already know the target file path or action type, record it; otherwise derive it later from the public interface contract.
- Keep intake to 1-2 questions; defer proof-field specifics until after capture.

Use this intake prompt (send to the user):
````
I can use Chrome DevTools to control a browser session and capture network requests. Is it OK if I do that?
Which platform are we targeting, and where in the UI does the data appear (list, detail, profile/settings)? If region changes the flow, mention it.
````

### 2. Required setup (login and context)
- If using MCP capture, attach to the user's existing Chrome session with remote debugging enabled instead of opening a fresh browser.
- Ask the user to log in and navigate to the relevant pages; capture requests as they browse.
- If the platform or flow is not yet known, ask them to show where the data appears; once they provide enough detail, start intercepting network requests.
- Follow the `chrome-devtools` skill workflow: navigate -> wait -> snapshot -> interact -> inspect network.
- Expect multiple rounds of navigation and capture; prompt the user to move through the UI while you refine selectors and re-capture as needed.

Use this setup prompt (send to the user):
````
Before we capture anything, please open `chrome://inspect/#remote-debugging` in the Chrome profile you want to reuse and turn on remote debugging. Then stay in that same logged-in Chrome session and start navigating to the page with the data. I'll attach there and capture requests as you browse.
````

### 3. Capture request(s)
- Ask for captured network requests from the MCP session. If not available, direct them to `references/network-capture.md` and request a sanitized capture.
- Request at least one request/response that includes the required proof fields.
- Check if multiple requests are needed (see "Handling Multiple Data Sources" below).
- If required proof fields were not specified, confirm them after you see candidate responses.
- Prefer `take_snapshot` over screenshots when navigating, and use `list_network_requests` plus `get_network_request` for the actual capture.

Use this capture prompt (send to the user):
````
Please navigate to the page where the data appears and perform the action that loads it. I will capture the request and response. If there is a list view and a detail view, open both so we can capture each request.
````

### 4. Identify candidate request(s)
- Prefer the endpoint that returns the required proof fields (list, detail, profile, or settings).
- Verify response type (JSON vs HTML) to choose JSONPath vs XPath extraction.
- For transaction providers, ensure the list extraction can consistently expose the fields the UI needs: `recipient`, `amount`, `date`, `paymentId`, and `currency` when relevant. Missing values will usually hide rows in the consumer UI.
- For payment platforms, check platform docs (and unofficial API references) to discover API domains/endpoints to watch for in capture. Use network access as needed to read docs and verify endpoints. Example: Monzo uses `api.monzo`, called with the UI session cookie.

### 5. Clarify endpoints and exploration
- Ask if there are other pages or endpoints worth exploring before locking on the request.
- If this is a payment/transaction proof, prompt the user to open a transaction list/history and then a specific transaction detail.
- Capture both list and detail endpoints; the list metadata URL can differ from the proof endpoint for a specific transaction (for example, Wise).
- If this is a brand new provider, settle the public path now: platform folder, `actionType`, and whether a `providers.json` manifest entry will be needed.

Use this clarification prompt (send to the user):
````
Are there other pages or tabs we should explore before we lock onto an endpoint? If this is a payment proof, please open a transaction list/history and then click a specific transaction so we can capture both list and detail requests.
````

### 6. Map fields to selectors
- Define `paramNames` and `paramSelectors` for dynamic parameters used in `url` and `body`.
- `paramNames` and `paramSelectors` are positional. Their order must stay aligned.
- Define `responseMatches` to validate proof fields.
- For regex `responseMatches`, use single-escaped patterns (one JSON-escape layer); avoid double-escaped strings like `\\\"`.
- Do not rely on `{{INDEX}}` inside `responseMatches`; current consumers forward them unchanged. Use `{{INDEX}}` in `transactionsExtraction`, `paramSelectors`, `proofMetadataSelectors`, and `responseRedactions` instead.
- If the flow requires a list UI for user selection, define `transactionsExtraction`; otherwise confirm whether it can be omitted.
- For JSONPath list extraction, the list selector must resolve to the transaction array itself. Each field selector runs against each list item.
- Treat `proofMetadataSelectors` as UI-facing metadata, not proof-enforced fields.
- Flag sensitive headers and add `responseRedactions`.
- Keep `responseRedactions` scoped to the same response object as `responseMatches`; for list responses, use `{{INDEX}}` so redactions align with the selected item.
- For fields from multiple sources, use appropriate `paramSelectors.source` values.
- If you use `metadataUrl`, keep it same-host `https` and remember that current consumers do not interpolate placeholders into `metadataUrlBody`.
- For payment flows, confirm recipient identifier stability via docs/help/FAQ using network access; explain the implications to the user. If the identifier is mutable or unclear, prefer a stable internal ID or add a second proof source. Do not ask the user to guess stability; only ask them to point to where the identifier appears in the UI if needed.
- For payment platforms, require only: recipient ID, amount, timestamp, and status (reversible vs settled); include currency when the platform supports multiple currencies. Ask where recipient IDs appear (can be multiple places) and whether amount is split into cents/dollars.
- If a second endpoint is required, decide whether it belongs in `metadataUrl` or `additionalProofs`. Use `additionalProofs` when a second notarized response must become part of the proof set.
- Summarize the mapping and confirm the required fields before assembling the final template.

Use this field confirmation prompt (send to the user):
````
I can extract the following fields from this response: <list fields>. Are these the exact fields you want to prove? If anything is missing or should be removed, tell me where it appears in the UI and I will capture that request.
````

### 7. Assemble the template
- Fill required top-level fields (`actionType`, `proofEngine`, `authLink`, `url`, `method`, `metadata`).
- Set `actionType` to reflect the use case (identity, account, transaction).
- Set `proofEngine` to `reclaim` for new templates.
- Use `references/provider-template.md` for a skeleton and `references/provider-fields.md` for deep field guidance.
- When possible, align choices with patterns in `references/provider-examples.md` (especially for payment and transaction templates).
- For multi-request flows, configure `additionalProofs` or `metadataUrl`.
- If the provider will be consumed by mobile, populate the `mobile` block deliberately:
  - `includeAdditionalCookieDomains`
  - `useExternalAction`
  - `userAgent`
  - `external` and/or `internal`
  - `login`
  - `mobile.additionalClientOptions`
- If this is a new provider in the public providers repo, include the matching `providers.json` manifest update.
- Hand back a short integration note for downstream wrapper configs: `authLink`, `actionPlatform`, `actionType`, `minExtensionVersion`, and `totalProofs` must stay aligned with the new JSON.

### 8. Test in the developer portal
- Confirm the user has already cloned the providers repo locally.
- Have the user test on `https://developer.zkp2p.xyz`.
- Ask them to install the PeerAuth extension: `https://chromewebstore.google.com/detail/peerauth-authenticate-and/ijpgccednehjpeclfcllnjjcmiohdjih`.
- In the developer settings dropdown, set the Providers URL to `http://localhost:8080`.
- If they are validating against a hosted providers service, ensure the public path resolves at `/providers/{platform}/{actionType}.json` and that the manifest includes the file.

### 9. Validate and iterate
- Use Chrome DevTools MCP to open a fresh browser window/session, have the user log in, and re-run the flow to confirm the endpoint is captured.
- Test in the providers dev flow (see docs in `references/provider-template.md`).
- If replay fails due to CSRF or nonce tokens, have the user re-run the action in the page and re-capture the request (avoid manual replay of stale requests).
- Tighten `urlRegex`, add `fallbackUrlRegex`, and refine selectors based on failures.
- If the proof succeeds but the user cannot select the intended row, inspect `transactionsExtraction` for missing/null fields or wrong list scoping.

---

## MCP-assisted capture (Chrome DevTools) - required

Chrome DevTools MCP must be installed before capture (see Skill installation and setup section). Use it to capture network requests directly (see `references/network-capture.md`).

Use an interactive flow:
- If MCP or the `chrome-devtools` skill is missing, ask the user to install or enable it before continuing.
- Ask the user to turn on remote debugging from `chrome://inspect/#remote-debugging` in the Chrome session they want to reuse.
- Ask for permission to control a Chrome session and access network data.
- Attach to that existing logged-in Chrome session instead of spawning a fresh browser (if the platform or flow is not yet known, ask them to show where the data lives before intercepting).
- Prefer the `chrome-devtools` skill sequence: `new_page` or `navigate_page` -> `wait_for` -> `take_snapshot` -> interaction -> `list_network_requests` -> `get_network_request`.
- After login, tell the user to start browsing and navigate to the page that contains the proof fields.
- If they did not already specify where the data lives, ask: "Which page should I click to reach the relevant data (profile, settings, history, transactions)?" and follow their suggested path.
- Ask: "Are there other pages or tabs I should click to reveal the required fields?" only if needed.
- Navigate the flow and trigger the relevant requests.
- Use `list_network_requests` to locate candidate requests and `get_network_request` (by `reqid`) to retrieve details.
- If response bodies are missing or obfuscated, ask for an alternate request or a different page to click.
- Do not switch to Playwright just because a flow is awkward. Use Playwright only if the user explicitly requests it or Chrome DevTools MCP cannot reach the target flow after attaching to the user's existing Chrome session.

---

## Handling Multiple Data Sources

Sometimes the required proof fields are not all in a single API response. Common scenarios:

### Scenario: Status or verification from a different endpoint
- The main response shows basic info (username, account ID, or transaction summary)
- Verification status or completion state requires a detail endpoint
- Solution: use `metadataUrl` when the second call is only needed to build the selection list. Use `additionalProofs` when the second call must become part of the final proof set.

### Scenario: Identity fields from separate API call
- One endpoint returns an account ID
- Another endpoint returns user profile info (username, display name)
- Solution:
  - Use `paramSelectors` with different `source` values to extract from multiple places.
  - Consider if a click-driven flow can trigger both requests.
  - Use `additionalProofs` if both responses must be proven.

### Scenario: Attribute in a different response than the main object
- The primary response contains the base object
- A related attribute lives in settings or headers
- Solution: use `paramSelectors` with `source: "responseHeaders"` or move the missing value into a second proof source.

### Scenario: Confirmation page after list view
- User must click an item to reveal the provable detail
- The detail request is what contains the verifiable data
- Solution: use `metadata.userInput` only if you have verified the target runtime supports it, then capture the triggered request and treat it as the actual proof candidate.

### What to ask the user
When you suspect multiple sources are needed, ask:
1. Which exact fields must be proven, and where do they appear?
2. Does clicking an item load additional details? If so, capture that request too.
3. Is status or verification shown somewhere else? Which request contains it?
4. Capture 2-3 different requests if you're unsure which has all the fields.
5. For payment platforms: where do recipient ID, amount (cents vs dollars), timestamp, status (reversible vs settled), and currency (if multi-currency) appear?

### Template fields for multi-source extraction

```json
{
  "paramSelectors": [
    { "type": "jsonPath", "value": "$.user.id", "source": "responseBody" },
    { "type": "jsonPath", "value": "$.user.username", "source": "responseBody" }
  ],
  "metadata": {
    "metadataUrl": "https://api.example.com/user/{{USER_ID}}",
    "metadataUrlMethod": "GET"
  },
  "additionalProofs": [
    {
      "url": "https://api.example.com/verification/{{USER_ID}}",
      "method": "GET",
      "responseMatches": [{ "type": "jsonPath", "value": "$.status" }]
    }
  ]
}
```

---

## Recovery loop
- Re-trigger the action in the UI to refresh CSRF/nonce tokens before capture.
- If the response is missing or obfuscated, try a different request or navigate to another page that loads the same data.
- If raw traffic cannot be shared, request a sanitized sample plus a field mapping table.
- If the user shares private runtime context, restate only the public interface implication in your final template notes.

## Gotchas and troubleshooting
- Some endpoints require CSRF or one-time tokens; always re-trigger the request in-page to refresh tokens before capture.
- Transaction list metadata and transaction detail proof endpoints can differ; capture both.
- HTML responses require XPath selectors; JSON responses use JSONPath.
- `metadataUrl` must stay same-host and `https` for current mobile replay behavior.
- `additionalProofs[].paramSelectors` are more limited than top-level selectors in some consumers. Keep them simple and sourced from the original response body unless you have verified more.
- Older docs mention fields such as `transactionRegexSelectors`, top-level `additionalClientOptions`, or custom WebView injection blocks. Do not introduce those shapes unless you have verified the target consumer actually supports them.

## Output expectations
- Default to producing a JSON template file (ask for `{platform}/{provider}.json` name if not provided).
- For payment and transaction providers, default to `{platform}/transfer_platform.json`.
- For payment platforms, confirm the required field set (recipient ID, amount, timestamp, status, and currency if multi-currency), avoid extra fields unless the user asks, and document any multi-source or split-amount handling.
- If the provider is new, include the `providers.json` manifest entry that should be added.
- If the provider is meant to ship in an app, include a short handoff note listing any downstream wrapper fields that must stay aligned.
- Provide a short mapping table: source field -> JSONPath/XPath/regex.
- Call out missing data in the capture and ask for additional requests.
- Note any fields that require multi-source extraction.
- Confirm the intended proof statement and required fields with the user.
- Keep all public-facing output free of private repo links, secrets, and raw sensitive captures.

## References
- `references/network-capture.md` for request collection and redaction guidance.
- `references/provider-template.md` for the skeleton and extraction patterns.
- `references/provider-fields.md` for field-by-field guidance.
- `references/provider-examples.md` for real public template patterns.
- `references/extension-template-parsing.md` for public-safe runtime behavior.
