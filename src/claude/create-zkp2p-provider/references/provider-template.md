# ZKP2P Provider Template Reference

For field-by-field detail, see `provider-fields.md`. For real public patterns, see `provider-examples.md`.

## Required fields (minimum)
- `actionType`
- `proofEngine` (`reclaim` for new templates)
- `authLink`
- `url`
- `method`
- `metadata`
  - `platform`
  - `urlRegex`
  - `method`
  - `transactionsExtraction` for transaction-selection flows
- `paramNames` and `paramSelectors` when placeholders exist
- `responseMatches`

## Common optional fields
- `skipRequestHeaders`
- `body`
- `secretHeaders`
- `responseRedactions`
- `metadata.fallbackUrlRegex`
- `metadata.fallbackMethod`
- `metadata.preprocessRegex`
- `metadata.shouldReplayRequestInPage`
- `metadata.metadataUrl`
- `metadata.metadataUrlMethod`
- `metadata.metadataUrlBody`
- `metadata.proofMetadataSelectors`
- `additionalProofs`
- `mobile`

## Path and manifest rules
- The public path is `{platform}/{actionType}.json`.
- `metadata.platform` should match `{platform}`.
- If the file is new in the public providers repo, add it to `providers.json`.

## Skeleton (current public shape)

```json
{
  "actionType": "transfer_example",
  "proofEngine": "reclaim",
  "authLink": "https://example.com/activity",
  "url": "https://api.example.com/payments/{{PAYMENT_ID}}",
  "method": "GET",
  "skipRequestHeaders": [],
  "body": "",
  "metadata": {
    "platform": "example",
    "urlRegex": "https://api\\.example\\.com/payments\\?limit=20$",
    "method": "GET",
    "fallbackUrlRegex": "",
    "fallbackMethod": "",
    "preprocessRegex": "",
    "shouldReplayRequestInPage": false,
    "transactionsExtraction": {
      "transactionJsonPathListSelector": "$.payments",
      "transactionJsonPathSelectors": {
        "recipient": "$.counterparty.id",
        "recipientName": "$.counterparty.name",
        "amount": "$.amount.value",
        "date": "$.createdAt",
        "paymentId": "$.id",
        "currency": "$.amount.currency",
        "status": "$.status"
      }
    },
    "proofMetadataSelectors": [
      { "type": "jsonPath", "value": "$.payments[{{INDEX}}].id" }
    ]
  },
  "paramNames": ["PAYMENT_ID"],
  "paramSelectors": [
    { "type": "jsonPath", "value": "$.payments[{{INDEX}}].id" }
  ],
  "secretHeaders": ["Authorization", "Cookie"],
  "responseMatches": [
    { "type": "regex", "value": "\"id\":\"(?<paymentId>[^\"]+)\"" },
    { "type": "regex", "value": "\"status\":\"(?<status>[^\"]+)\"" }
  ],
  "responseRedactions": [
    { "jsonPath": "$.id" },
    { "jsonPath": "$.status" }
  ],
  "additionalProofs": [],
  "mobile": {
    "includeAdditionalCookieDomains": [],
    "useExternalAction": true,
    "userAgent": {
      "android": "Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.6367.207 Mobile Safari/537.36",
      "ios": "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15"
    },
    "external": {
      "actionLink": "example://pay/{{RECIPIENT_ID}}?amount={{AMOUNT}}",
      "appStoreLink": "https://apps.apple.com/example",
      "playStoreLink": "https://play.google.com/store/apps/details?id=com.example"
    },
    "login": {
      "usernameSelector": "input[type=\"email\"]",
      "passwordSelector": "input[type=\"password\"]",
      "submitSelector": "button[type=\"submit\"]",
      "revealTimeoutMs": 5000
    },
    "additionalClientOptions": {
      "cipherSuites": ["TLS_AES_128_GCM_SHA256"]
    }
  }
}
```

## Optional compatibility fields

Some current public templates also include extension-oriented fields such as:

```json
{
  "metadata": {
    "shouldSkipCloseTab": true,
    "userInput": {
      "promptText": "Select a transaction",
      "transactionXpath": "//li[@data-transaction]"
    }
  }
}
```

Use those only when you have verified the target runtime supports them.

## metadataUrl example

Use `metadataUrl` when the list endpoint needed for row selection differs from the final proof endpoint.

```json
{
  "metadata": {
    "metadataUrl": "https://api.example.com/payments?page=0&size=20",
    "metadataUrlMethod": "GET",
    "metadataUrlBody": ""
  }
}
```

Notes:
- Current mobile replay behavior expects `metadataUrl` to stay same-host and `https`.
- URL placeholders are interpolated. `metadataUrlBody` is not.

## additionalProofs example

Use `additionalProofs` when a second response must become part of the final proof set.

```json
{
  "additionalProofs": [
    {
      "url": "https://api.example.com/payments/detail",
      "method": "POST",
      "body": "paymentId={{PAYMENT_ID}}",
      "paramNames": ["PAYMENT_ID"],
      "paramSelectors": [
        { "type": "jsonPath", "value": "$.payments[{{INDEX}}].id" }
      ],
      "skipRequestHeaders": ["Accept-Encoding"],
      "secretHeaders": ["Authorization", "Cookie"],
      "responseMatches": [
        { "type": "regex", "value": "\"recipientEmail\":\"(?<recipientEmail>[^\"]+)\"" }
      ],
      "responseRedactions": [
        { "jsonPath": "$.recipientEmail" }
      ]
    }
  ]
}
```

Notes:
- Keep `additionalProofs[].paramSelectors` simple.
- If a downstream wrapper exposes `totalProofs`, keep it aligned with the actual proof count.

## Authoring notes
- Use JSONPath for JSON and XPath for HTML.
- Keep `transactionsExtraction` minimal so rows do not disappear due to missing fields.
- Keep `responseMatches` proof-focused.
- Use `responseRedactions` for `{{INDEX}}`-specific cleanup on list responses.
- Do not use older shapes such as top-level `additionalClientOptions` or `mobile.actionLink` unless you have verified them.

## Quick test
- Run the providers repo locally and expose it at `http://localhost:8080/`.
- Open `https://developer.zkp2p.xyz/`.
- Point the provider base URL at `http://localhost:8080/`.
- Test the public path `http://localhost:8080/{platform}/{actionType}.json`.
- Authenticate, inspect metadata rows, then prove a specific transaction.
