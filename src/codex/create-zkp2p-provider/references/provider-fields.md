# Provider Field Reference

This reference is aligned to the current public provider JSON contract used by ZKP2P consumers. It intentionally avoids private repo references and focuses on stable interface behavior.

## Public contract first

Before filling individual fields, lock down these invariants:
- The provider file path is `{platform}/{actionType}.json`.
- `metadata.platform` should match the folder name and any manifest entry in `providers.json`.
- `actionType` should match the action string used by downstream wrappers and developer tools.
- Keep the JSON schema current. Do not invent fields from older docs unless you have verified a current consumer still supports them.

## Basic configuration

### actionType (required)
- Purpose: identifies the action (for example, `transfer_wise`).
- Use: keep it stable, unique, and aligned with the file name.

### proofEngine (required for new templates)
- Purpose: selects the proof engine.
- Use: set to `reclaim` for new templates.

### authLink (required)
- Purpose: the page the user must open or authenticate against.
- Use: point to the page that naturally exposes the data you are about to capture.

### url (required)
- Purpose: the main notarized request URL.
- Use: placeholders such as `{{PAYMENT_ID}}` must appear in `paramNames`.

### method (required)
- Purpose: HTTP method for the main request.
- Use: copy the observed method exactly.

### body (optional)
- Purpose: request body template for POST-like requests.
- Use: include placeholders only when the body truly changes per selected item.

### skipRequestHeaders (optional)
- Purpose: headers to omit from the notarized request.
- Use: remove unstable noise, but do not remove headers required for the target request to succeed.
- Runtime detail: some current consumers send no headers when this list is empty, and send "all except skipped" when it is not.

### countryCode (optional)
- Purpose: geo-hints for the proof engine.
- Use: only set it when the proof truly depends on region.

## metadata

### platform (required)
- Purpose: platform identifier string.
- Use: should equal the folder name in the public path.

### urlRegex (required)
- Purpose: matches the intercepted request used for metadata extraction.
- Use: escape regex metacharacters and keep the pattern tight enough to avoid unrelated requests.

### method (required)
- Purpose: request method for metadata interception.
- Use: must match the intercepted request method.

### fallbackUrlRegex / fallbackMethod (optional)
- Purpose: backup intercept when the primary endpoint is inconsistent.
- Use: use them sparingly; they complicate debugging.

### preprocessRegex (optional)
- Purpose: strips JSON out of HTML or other wrappers before JSONPath extraction.
- Use: supply a single capture group that isolates the JSON payload.

### shouldReplayRequestInPage (optional)
- Purpose: replays the request in the page context instead of a generic fetch.
- Use: needed for some SPAs or pages with in-page auth or CORS constraints.

### metadataUrl / metadataUrlMethod / metadataUrlBody (optional)
- Purpose: replays a separate request to build metadata rows.
- Use: choose this when the list endpoint for UI selection differs from the final proof endpoint.
- Runtime detail: current mobile replay logic expects `metadataUrl` to stay same-host and `https`.
- Runtime detail: placeholders are interpolated in the URL, not in `metadataUrlBody`.

### transactionsExtraction (required for transaction selection UIs)
- Purpose: defines how the UI builds the list of selectable rows.
- JSON response fields:
  - `transactionJsonPathListSelector`
  - `transactionJsonPathSelectors`
- HTML response fields:
  - `transactionXPathListSelector`
  - `transactionXPathSelectors`
- Use JSONPath for JSON and XPath for HTML. Do not mix them unless you have verified the consumer needs both.
- Consumer behavior: missing or null extracted fields usually hide the row, so keep the field set minimal and consistently extractable.
- Common fields in public templates:
  - `recipient`
  - `recipientName`
  - `amount`
  - `date`
  - `paymentId`
  - `currency`
  - `status`
  - `type`
- Payment platforms should prioritize recipient ID, amount, timestamp/date, and status. Add currency when the platform supports more than one currency.

### proofMetadataSelectors (optional)
- Purpose: UI-facing metadata derived from the intercepted response.
- Use: keep them aligned with the selected row, but do not treat them as proof-enforced fields.

### Compatibility fields seen in current public templates

#### metadata.userInput (optional)
- Purpose: instructs an extension-style runtime to prompt the user to click a specific element before metadata arrives.
- Fields:
  - `promptText`
  - `transactionXpath`
- Use: only when the detail request fires after a click and you have verified the target runtime honors it.

#### metadata.shouldSkipCloseTab (optional)
- Purpose: keeps the auth tab open after authentication.
- Use: only when closing the tab would kill the session needed for replay.

## Parameter extraction

### paramNames (required when placeholders exist)
- Purpose: ordered list of placeholder names used in `url` or `body`.
- Use: every `{{NAME}}` in the template should appear here.

### paramSelectors (required when placeholders exist)
- Purpose: ordered extraction rules for each param.
- Fields:
  - `type`: `jsonPath`, `regex`, or `xPath`
  - `value`: selector string
  - `source`: `url`, `responseBody`, `responseHeaders`, `requestHeaders`, or `requestBody`
- Use: `paramNames` and `paramSelectors` are positional. Keep them in the same order.
- Regex selectors should use a capture group when you want a specific sub-value.

## Security

### secretHeaders (optional)
- Purpose: mark sensitive headers so they are handled as secrets.
- Use: include auth material such as `Cookie`, `Authorization`, or platform-specific session headers.

### responseRedactions (optional)
- Purpose: redact sensitive or unnecessary response fields.
- Fields:
  - `jsonPath`
  - `xPath`
  - `regex`
- Use: scope redactions to the same response object as `responseMatches`.
- Use `{{INDEX}}` for list responses so the redaction follows the selected row.

## Response verification

### responseMatches (required)
- Purpose: binds proof-relevant fields from the final response.
- Fields:
  - `type`: `jsonPath` or `regex`
  - `value`
  - `hash` (optional)
- Use: keep them minimal. Bind only what the proof actually needs.
- Regex escaping: use single-escaped patterns suitable for JSON files.
- Runtime detail: do not rely on `{{INDEX}}` interpolation in `responseMatches`; some consumers forward them unchanged.

## additionalProofs

### additionalProofs (optional)
- Purpose: generates more than one notarized proof for a single provider flow.
- Each entry can define:
  - `url`
  - `method`
  - `body`
  - `paramNames`
  - `paramSelectors`
  - `skipRequestHeaders`
  - `secretHeaders`
  - `responseMatches`
  - `responseRedactions`
- Use: choose this when a second endpoint must be independently proven, not just replayed for metadata.
- Downstream implication: if a consumer wrapper exposes `totalProofs`, it should stay aligned with the number of proofs the provider actually needs.
- Runtime caution: some current consumers resolve additional-proof params only from the original response body with simple JSONPath and regex flows. Keep these selectors straightforward unless you have verified the target runtime.

## mobile

### mobile.includeAdditionalCookieDomains
- Purpose: extends the cookie domain set for mobile replay flows.
- Use: add domains only when the same session spans multiple related hosts.

### mobile.useExternalAction
- Purpose: chooses whether native-app deep links should be preferred over internal WebView flows.
- Use: `true` means prefer `mobile.external`, otherwise prefer `mobile.internal`.

### mobile.userAgent
- Purpose: overrides the replay/browser user agent for Android and iOS.
- Use: copy existing public template patterns when a platform behaves differently by user agent.

### mobile.additionalClientOptions
- Purpose: mobile-only transport overrides.
- Current public shape:
  - `cipherSuites`
  - `supportedProtocolVersions`
- Use: keep this nested under `mobile`. Older top-level examples are outdated.

### mobile.external
- Purpose: deep links into the native app.
- Fields:
  - `actionLink`
  - `appStoreLink`
  - `playStoreLink`
- Use: interpolate only values the mobile runtime can actually provide, such as `{{RECIPIENT_ID}}` or `{{AMOUNT}}`.

### mobile.internal
- Purpose: uses an internal browser or WebView action instead of a native deep link.
- Fields:
  - `actionLink`
  - `actionCompletedUrlRegex` (optional)
- Use: use when the target flow works better in a WebView than in the native app.

### mobile.login
- Purpose: optional login assist selectors.
- Fields:
  - `usernameSelector`
  - `passwordSelector`
  - `submitSelector`
  - `nextSelector`
  - `revealTimeoutMs`
- Use: make these broad enough to survive small UI changes, but not so broad that they hit the wrong form.

## Legacy or drift-prone fields

Older docs mention shapes such as:
- top-level `additionalClientOptions`
- `mobile.actionLink`
- `isExternalLink`
- `transactionRegexSelectors`
- custom injected WebView JavaScript blocks

Do not use those fields by default. They do not match the current public contract we validated for this skill.

## Best practices
- Escape regex metacharacters in `urlRegex`.
- Use JSONPath for JSON and XPath for HTML.
- Keep `transactionsExtraction` minimal so rows do not disappear due to missing fields.
- Use stable recipient identifiers when available.
- Keep `responseMatches` small and proof-relevant.
- Redact everything you do not need.
- Prefer Chrome DevTools MCP over Playwright for capture and debug loops.

## Common issues
- Auth link opens but no metadata arrives: `metadata.urlRegex` or `metadata.method` is wrong.
- Metadata rows are empty or hidden: the list selector or one of the extracted fields is wrong.
- Replay works for metadata but proof fails: check `skipRequestHeaders`, `secretHeaders`, and `responseRedactions`.
- Params are blank: the `source` is wrong, or `paramNames` and `paramSelectors` are out of order.
- Mobile flow opens the wrong app/page: verify the `mobile.external` vs `mobile.internal` shape and `useExternalAction` setting.
