# Extension Template Parsing Logic (Public Reference)

This reference documents the extension's template parsing behavior in a public-safe way (no private file paths). It reflects the actual behavior of the extension implementation and is intended as a precise guide for authoring provider templates. If your private build diverges, treat this as the baseline and verify via logs.

## ProviderSettings schema (authoritative behavior)
The extension expects a provider config with these fields and semantics:

- Top-level:
  - `actionType`, `authLink`, `url`, `method`, `skipRequestHeaders`, `body`.
  - `countryCode` (optional) is forwarded as `geoLocation` in claim params.
  - `paramNames` and `paramSelectors` (order must align).
  - `secretHeaders`.
  - `responseMatches` and `responseRedactions`.
  - `additionalClientOptions` (optional; e.g., cipher suites).
  - `additionalProofs` (optional array; see below).

- `metadata`:
  - `platform`, `urlRegex`, `method`.
  - `fallbackUrlRegex`, `fallbackMethod`.
  - `preprocessRegex`.
  - `shouldReplayRequestInPage`, `shouldSkipCloseTab`.
  - `userInput` with `promptText` and `transactionXpath`.
  - `metadataUrl`, `metadataUrlMethod`, `metadataUrlBody`.
  - `transactionsExtraction` with JSONPath and/or XPath selectors.
  - `proofMetadataSelectors` (array of `{type, value}`), used for UI metadata strings.

## Provider config loading and intercept patterns
- The extension fetches the provider config from a base URL + `{platform}/{actionType}.json`.
- Intercept patterns are built from:
  - `metadata.urlRegex`
  - `metadata.fallbackUrlRegex`
  - `metadata.metadataUrl` (if set), with `{{PARAM}}` replaced by `\\S+` to form a regex-like pattern.
- `metadata.shouldReplayRequestInPage` is stored per tab and used during replay.
- `metadata.userInput` is stored in tab-scoped storage and consumed by the content script.

## User input overlay (click guide)
- Renders only if `metadata.userInput.transactionXpath` exists and matches visible elements on the page.
- If the XPath returns no visible elements, the overlay does not appear and no error is thrown.
- Clicking a highlighted element does not trigger extraction by itself; it just keeps the overlay until a metadata intercept arrives.

## Metadata extraction pipeline
1. Offscreen collects request logs for the auth tab.
2. The extension searches for a matching request using `metadata.method + metadata.urlRegex`.
3. If none is found, it tries `metadata.fallbackMethod + metadata.fallbackUrlRegex`.
4. `metadata.metadataUrl` changes behavior:
   - If set, the extension replays a request to `metadataUrl` using a found/fallback request as context.
   - If no context request exists, it errors with a clear message.
5. Without `metadataUrl`:
   - If a matching request is found, it uses the intercepted response body.
   - If only fallback exists, it replays the fallback request (does not use stored fallback response).
6. Extracted transactions are sent as metadata rows. If zero rows are extracted, the UI receives an empty list plus an error message.

## Response body normalization and parsing
- If the response is a string:
  - It attempts JSON parsing; if it fails, JSON is undefined and the raw string is kept.
  - Double-stringified JSON is handled by unescaping `\"` and parsing again.
- If a response object is returned, it is stringified and used as JSON directly.
- `preprocessRegex`:
  - If set, capture group 1 is extracted and parsed as JSON.
  - If the regex does not match, parsing returns `undefined` (extraction will likely fail).

## Transaction extraction (JSONPath and XPath)
### JSONPath
- If `transactionJsonPathListSelector` is set:
  - The extension evaluates JSONPath and expects `list[0]` to be the array of transactions.
  - Each transaction item is passed to field selectors; selectors should be relative to the item.
- If no list selector, selectors run against the root JSON object.
- `{{INDEX}}` is interpolated into selector strings before evaluation.
- A transaction is marked `hidden: true` if any field is `undefined` or `null`.

### XPath
- If `transactionXPathListSelector` is set:
  - The selector yields a snapshot list of nodes.
  - Field selectors are evaluated with the list item as the context node.
- If no list selector, selectors run against the document root.
- `{{INDEX}}` is interpolated into selector strings.
- A transaction is marked `hidden: true` if any field is `undefined`, `null`, or an empty string.

## Selector evaluation semantics
- `{{INDEX}}` is replaced via a literal string substitution (no arithmetic or expressions).
- Regex selectors:
  - Compiled with the global flag (`/g`).
  - All matches are collected; the match at `min(index, lastMatch)` is selected.
  - Returns capture group 1 if present; otherwise returns the full match.
- XPath selectors:
  - Evaluated as `XPathResult.STRING_TYPE` and trimmed.

## Param selector extraction
- `paramNames` and `paramSelectors` are positionally aligned; order must match.
- `paramSelectors.source` defaults to `responseBody` if omitted.
- Sources:
  - `responseBody`: uses response body string.
  - `requestBody`: uses intercepted request body.
  - `requestHeaders` / `responseHeaders`: headers are converted to JSON strings.
  - `url`: uses request URL. For JSONPath, it wraps into `{ "url": "..." }`.
- JSONPath param selectors parse JSON from the source string (except when source is `url`).

## metadataUrl behavior and constraints
- `metadataUrl` is used for replay if set.
- The target must be `https` and must match the host of the context request, or an error is thrown.
- `metadataUrlMethod`/`metadataUrlBody` override `method`/`body` for the replay.
- Only URL placeholders are interpolated (URL-encoded). The body is not interpolated.
- If XPath extraction is configured, the replay uses text response; otherwise JSON.

## Proof metadata strings (UI)
- The `Date` response header is included if present.
- `proofMetadataSelectors` are evaluated in order:
  - `regex` uses the same regex rules described above.
  - `xPath` evaluates against HTML parsed from the response body string.
  - Other types are treated as JSONPath.
- JSONPath selectors run against a safe JSON parse of the response string.
- Results are pushed as-is; arrays are not flattened.

## Claim request building (proof generation)
- `paramValues` are computed from `paramSelectors` and passed to the proof engine.
  - The extension does not substitute param values into `url` or `body` itself.
- `responseMatches` are passed through unchanged (no `{{INDEX}}` interpolation).
- `responseRedactions` are interpolated with `{{INDEX}}`.
- `skipRequestHeaders` behavior:
  - If empty, `headers` is an empty object.
  - If non-empty, it includes all headers except those in the skip list.
- `secretHeaders` behavior:
  - `Cookie` is stored as `secretParams.cookieStr`.
  - Other headers go into `secretParams.headers`.
- `additionalClientOptions` and `countryCode` are forwarded into claim params when present.

## Additional proofs
- If `proofIndex > 0`, the extension uses `additionalProofs[proofIndex - 1]` as the active config for the proof.
- UI metadata strings still use the main `providerConfig` (not the additional proof config).

## Metadata message shape (UI)
Each extracted row includes fields like:
- `recipient`, `amount`, `date`, `currency`, `paymentId`, `type`, `recipientName`
- `originalIndex` (used for `{{INDEX}}` resolution)
- `hidden` (used to filter incomplete rows)

## Authoring implications
- Ensure JSONPath list selectors return an array as the first match (`list[0]`).
- Avoid missing fields; any missing field will mark the row as hidden.
- Use capture groups in regex selectors if you want only a specific value.
- Do not rely on `{{INDEX}}` in `responseMatches`; it is not interpolated there.
- Keep `responseRedactions` scoped to the same response object as `responseMatches`; use `{{INDEX}}` for list responses.
- If you use `metadataUrl`, confirm same-host HTTPS, and remember body is not interpolated.
