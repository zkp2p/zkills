---
name: zkp2p-provider-template
description: Guide users to build or update ZKP2P provider templates (zkTLS/Reclaim) by capturing payment-platform network requests, mapping transaction fields (amount, date, recipient, status/currency), and producing the JSON provider template. Use when asked to create a ZKP2P provider template, analyze HAR/network logs, or translate API responses into template fields.
---

# ZKP2P Provider Template

## Overview
Guide users to turn payment-platform network requests into a valid ZKP2P provider JSON template with safe redaction and testable extraction rules.

## Workflow
1. Intake and request capture
   - Ask which platform, region, and transaction flow (send vs receive) they are integrating.
   - Ask for captured network requests (HAR/export or PeerAuth intercepted requests). If not available, direct them to `references/network-capture.md` and request a sanitized capture.
   - Request at least one request/response that includes amount, date/timestamp, recipient ID/name, and ideally status/currency.

2. Identify candidate request(s)
   - Prefer the endpoint that returns a transaction list or transaction detail payload.
   - Verify response type (JSON vs HTML) to choose JSONPath vs XPath extraction.

3. Map fields to selectors
   - Define `paramNames` and `paramSelectors` for dynamic parameters used in `url`/`body`.
   - Define `transactionsExtraction` selectors and `responseMatches` to validate proof fields.
   - Flag sensitive headers and add `responseRedactions`.

4. Assemble the template
   - Fill required top-level fields (`actionType`, `proofEngine`, `authLink`, `url`, `method`, `metadata`).
   - Set `proofEngine` to `"reclaim"` for new templates.
   - Use `references/provider-template.md` for a skeleton and `references/provider-fields.md` for deep field guidance.
   - When possible, align choices with patterns in `references/provider-examples.md`.

5. Validate and iterate
   - Test in the providers dev flow (see docs in `references/provider-template.md`).
   - Tighten `urlRegex`, add `fallbackUrlRegex`, and refine selectors based on failures.

## Output expectations
- Default to producing a JSON template file (ask for `{platform}/{provider}.json` name if not provided).
- Provide a short mapping table: source field -> JSONPath/XPath/regex.
- Call out missing data in the capture and ask for additional requests.

## References
- `references/network-capture.md` for request collection and redaction guidance.
- `references/provider-template.md` for the skeleton and extraction patterns.
- `references/provider-fields.md` for detailed field-by-field guidance from the docs.
- `references/provider-examples.md` for real templates from the providers repo.
- `references/extension-template-parsing.md` for exact extension parsing logic.
