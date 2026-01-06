# Provider Field Reference (from ZKP2P docs)

This reference expands on the official "Build a New Provider" doc with field-by-field guidance and common pitfalls. It only covers fields documented there.

## Basic configuration

### actionType (required)
- Purpose: Identifier for the action type (e.g., "transfer_venmo").
- Use: Must be unique per provider; keep consistent with the platform and flow (send vs receive).

### proofEngine (required for new templates)
- Purpose: Selects the proof/attestation engine.
- Use: Set to "reclaim" for all new templates.

### authLink (required)
- Purpose: URL for user authentication/login.
- Use: Link to the page where the user is already authenticated or can log in.

### url (required)
- Purpose: Main endpoint to fetch or verify transaction data.
- Use: Can include placeholders like {{SENDER_ID}}; placeholders must appear in paramNames.

### method (required)
- Purpose: HTTP method for the main request.
- Use: Must match the observed request method (GET/POST/PUT/PATCH).

### skipRequestHeaders (optional)
- Purpose: Headers to exclude from notarized request.
- Use: Exclude noisy or variable headers that can cause mismatches; do not exclude required auth headers.

### body (optional)
- Purpose: Request body template for POST/PUT.
- Use: Include placeholders for dynamic values (defined in paramNames). Leave empty for GET.

## metadata (required)

### platform (required)
- Purpose: Platform identifier string (e.g., "venmo").
- Use: Should match the platform folder name used in the providers repo.

### urlRegex (required)
- Purpose: Match the request URL used for metadata extraction.
- Use: Escape dots and special chars (\\.), and keep the pattern specific to avoid false matches.

### method (required)
- Purpose: Method for the metadata extraction request.
- Use: Must match the intercepted request method.

### fallbackUrlRegex / fallbackMethod (optional)
- Purpose: Alternative URL/method when the primary endpoint fails or varies.
- Use: Use for platforms with multiple endpoints or conditional flows.

### preprocessRegex (optional)
- Purpose: Extract embedded JSON from HTML or other wrappers.
- Use: Supply a regex with a capture group to isolate JSON before JSONPath extraction.

### shouldReplayRequestInPage (optional)
- Purpose: Replay the request in the page context instead of the extension.
- Use: Required for some SPAs or apps that enforce in-page calls.

### shouldSkipCloseTab (optional)
- Purpose: Keep the auth tab open after successful authentication.
- Use: Helpful when users need to perform extra steps after auth.

### userInput (optional)
- Purpose: Prompt user to click a transaction element to trigger the detail request.
- Fields:
  - promptText: short instruction shown in-page.
  - transactionXpath: XPath selecting clickable transaction nodes.
- Use: Critical when a detail request only fires after a click. Prefer stable attributes over volatile classes.

### transactionsExtraction (required for transaction list UI)
- Purpose: Provide selectors to list transactions for user selection.
- JSON response:
  - transactionJsonPathListSelector: JSONPath that points to the list.
  - transactionJsonPathSelectors: JSONPath per field (amount/date/recipient/paymentId/currency).
- HTML response:
  - transactionXPathListSelector: XPath that selects each transaction row.
  - transactionXPathSelectors: XPath per field.
- Use: Only one of JSONPath or XPath lists is needed; choose based on response type.
- Recipient identifiers: In `transaction*Selectors`, ensure `recipient` is a unique, stable identifier. If the platform allows changes, confirm changes invalidate payments (safe) rather than redirect funds (e.g., a Zelle email change invalidates the payment).

### proofMetadataSelectors (optional)
- Purpose: Additional selectors whose values are included in the proof metadata.
- Use: Include values that must be bound to the proof beyond responseMatches.

## Parameter extraction

### paramNames (required)
- Purpose: List of placeholder names used in url/body.
- Use: Each {{NAME}} must appear in this list.

### paramSelectors (required)
- Purpose: Extraction rules for parameter values.
- Fields:
  - type: jsonPath | regex | xPath
  - value: selector string
  - source: url | responseBody | responseHeaders | requestHeaders | requestBody (default responseBody)
- Use: For regex selectors, include capture groups (). Use source when extracting from non-default locations.

## Security

### secretHeaders (optional)
- Purpose: List of headers containing sensitive data.
- Use: Include auth headers like Authorization/Cookie so they are handled safely.

## Response verification

### responseMatches (required)
- Purpose: Patterns used to verify data in the response.
- Fields:
  - type: jsonPath | regex
  - value: selector/pattern
  - hash: optional boolean
- Use: Keep matches minimal for performance; never include secrets in responseMatches.

### responseRedactions (optional)
- Purpose: Remove PII or sensitive fields from the response.
- Fields:
  - jsonPath or xPath
- Use: Redact user identifiers, tokens, or unrelated data while keeping required proof fields intact.

## Mobile SDK (optional)

### includeAdditionalCookieDomains
- Purpose: Include extra domains for cookies.
- Use: Add domains required to authenticate the request in mobile contexts.

### actionLink / isExternalLink / appStoreLink / playStoreLink
- Purpose: Deep link to the mobile app and store links for installation.
- Use: Use placeholders for dynamic values in actionLink; set isExternalLink when needed.

## Best practices (from docs)
- Escape special characters in urlRegex and keep patterns specific.
- Use JSONPath for JSON responses and XPath for HTML responses.
- For regex selectors, always use capture groups.
- Specify source for paramSelectors when not using responseBody.
- Add secretHeaders and responseRedactions to protect PII.
- Use fallback URLs and preprocessRegex for complex responses.
- Minimize responseMatches and avoid wildcards when possible.

## Common issues (from docs)
- Auth link not opening: verify extension Base URL and local server.
- Authenticated but not redirected: urlRegex mismatch.
- Prove fails after metadata: check responseRedactions and headers.
- Parameters not extracted: verify paramSelectors source.
