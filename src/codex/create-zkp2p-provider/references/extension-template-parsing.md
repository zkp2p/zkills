# Runtime Template Behavior (Public-safe Baseline)

This reference documents the public-safe provider behavior that matters when authoring templates. It focuses on shared interface rules and the current typed mobile runtime behavior, then calls out extension-oriented compatibility fields that still appear in public templates.

## Shared file-resolution contract

- Consumers resolve provider configs at `baseUrl + {platform}/{actionType}.json`.
- Public manifests list files in `providers.json`.
- Keep the folder name, `metadata.platform`, and `actionType` aligned.

## Current typed provider shape

The current public runtime shape includes:
- Top-level:
  - `actionType`
  - `authLink`
  - `url`
  - `method`
  - `skipRequestHeaders`
  - `body`
  - `countryCode` (optional)
  - `paramNames`
  - `paramSelectors`
  - `secretHeaders`
  - `responseMatches`
  - `responseRedactions`
  - `additionalProofs` (optional)
  - `mobile` (optional)
- `metadata`:
  - `platform`
  - `urlRegex`
  - `method`
  - `fallbackUrlRegex`
  - `fallbackMethod`
  - `preprocessRegex`
  - `shouldReplayRequestInPage`
  - `transactionsExtraction`
  - `proofMetadataSelectors`
  - `metadataUrl`
  - `metadataUrlMethod`
  - `metadataUrlBody`

## Metadata extraction behavior

### JSONPath and XPath selection
- `transactionsExtraction.transactionJsonPathListSelector` should resolve to the list array itself.
- Each `transactionJsonPathSelectors` entry runs relative to each list item.
- `transactionXPathListSelector` yields a node list; each XPath field selector runs relative to one node.
- Missing or null extracted values usually hide the row in the selection UI.

### preprocessRegex
- If present, a capture group is used to pull JSON-like content out of a wrapper response.
- Use it for HTML pages that embed JSON inside a `<script>` or `<pre>` block.

### metadataUrl
- If set, replay logic prefers `metadataUrl` over the intercepted response URL for metadata reconstruction.
- Current mobile replay behavior expects `metadataUrl` to stay same-host and `https`.
- `metadataUrlMethod` and `metadataUrlBody` override the replay request.
- URL placeholders are interpolated. `metadataUrlBody` is not.

## Param extraction behavior

- `paramNames` and `paramSelectors` are positional. Order matters.
- `paramSelectors.source` defaults to `responseBody`.
- Supported sources:
  - `responseBody`
  - `requestBody`
  - `requestHeaders`
  - `responseHeaders`
  - `url`
- JSONPath selectors against `url` operate on a wrapped object such as `{ "url": "..." }`.

## Claim-building behavior

- `responseMatches` are forwarded unchanged to the proof engine.
- Do not rely on `{{INDEX}}` interpolation in `responseMatches`.
- `responseRedactions` do support `{{INDEX}}` substitution in current runtimes.
- `skipRequestHeaders` is applied before the final request is sent to the proof engine.
- `secretHeaders` are split into secret request data such as cookies and protected headers.
- `countryCode` is forwarded as a geo hint when present.
- `mobile.additionalClientOptions` is forwarded into claim options when present.

## additionalProofs behavior

- `additionalProofs` allow multiple notarized responses for one provider flow.
- Each additional proof can override:
  - `url`
  - `method`
  - `body`
  - `paramNames`
  - `paramSelectors`
  - `skipRequestHeaders`
  - `secretHeaders`
  - `responseMatches`
  - `responseRedactions`
- Current mobile logic derives additional-proof params from the original response body with straightforward JSONPath or regex extraction. Do not assume every top-level selector behavior is mirrored there.

## Mobile action routing

- `mobile.useExternalAction: true` means prefer `mobile.external`.
- Otherwise, prefer `mobile.internal` when present.
- `mobile.external` typically contains:
  - `actionLink`
  - `appStoreLink`
  - `playStoreLink`
- `mobile.internal` typically contains:
  - `actionLink`
  - `actionCompletedUrlRegex` (optional)
- `mobile.login` contains selector hints for login assistance.
- `mobile.userAgent` overrides browser identity for replay and WebView flows.

## Compatibility fields still seen in public templates

These fields appear in current public provider JSON, but they are not part of the narrower typed mobile contract above:
- `metadata.userInput`
- `metadata.shouldSkipCloseTab`

Treat them as extension-oriented compatibility fields:
- `metadata.userInput` is useful for click-driven detail flows.
- `metadata.shouldSkipCloseTab` is useful when the session would die if the auth tab closed too early.

If you use them, verify them against the target runtime instead of assuming every consumer honors them.

## Legacy drift to avoid

Older public docs mention shapes such as:
- top-level `additionalClientOptions`
- `mobile.actionLink`
- `isExternalLink`
- `transactionRegexSelectors`
- custom injected WebView JavaScript blocks

Do not default to those shapes. They do not match the current public contract used in this skill.

## Authoring implications

- Keep the public path stable: `{platform}/{actionType}.json`.
- Keep list extraction minimal and reliable so rows do not disappear.
- Use `responseMatches` only for proof-relevant fields.
- Use `responseRedactions` to clean up selected-row data.
- Prefer `metadataUrl` for alternate list replay and `additionalProofs` for extra notarized responses.
- Prefer Chrome DevTools MCP over Playwright for capture and debugging loops.
- If you learned a constraint from a non-public repo, convert it into a public interface rule before writing it down here.
