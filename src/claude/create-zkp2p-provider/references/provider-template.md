# ZKP2P Provider Template Reference

For deeper field-by-field guidance, see `provider-fields.md`. For real examples, see `provider-examples.md`.

## Required fields (minimum)
- actionType
- proofEngine (use "reclaim")
- authLink
- url
- method
- metadata (platform, urlRegex, method; include transactionsExtraction for transaction list UI)
- paramNames
- paramSelectors
- responseMatches

## Optional fields (common)
- skipRequestHeaders
- body
- secretHeaders
- responseRedactions
- mobile
- metadata.fallbackUrlRegex / fallbackMethod
- metadata.userInput
- metadata.proofMetadataSelectors

## Skeleton (trim as needed)
This skeleton is transaction-list oriented. For identity-only or account-attribute proofs, focus on `responseMatches` and omit `transactionsExtraction` if the runtime allows it.
```json
{
  "actionType": "transfer_example",
  "proofEngine": "reclaim",
  "authLink": "https://example.com/login",
  "url": "https://api.example.com/transactions?userId={{USER_ID}}",
  "method": "GET",
  "skipRequestHeaders": [],
  "body": "",
  "metadata": {
    "platform": "example",
    "urlRegex": "https://api\\.example\\.com/transactions\\?userId=\\S+",
    "method": "GET",
    "fallbackUrlRegex": "",
    "fallbackMethod": "",
    "shouldReplayRequestInPage": false,
    "shouldSkipCloseTab": false,
    "userInput": {
      "promptText": "Select a transaction",
      "transactionXpath": "//div[@data-transaction]"
    },
    "transactionsExtraction": {
      "transactionJsonPathListSelector": "$.data.transactions",
      "transactionJsonPathSelectors": {
        "recipient": "$.counterparty.name",
        "amount": "$.amount",
        "date": "$.created_at",
        "paymentId": "$.id",
        "currency": "$.currency"
      },
      "transactionXPathListSelector": "",
      "transactionXPathSelectors": {}
    },
    "proofMetadataSelectors": []
  },
  "paramNames": ["USER_ID"],
  "paramSelectors": [
    {
      "type": "regex",
      "value": "userId=([^&]+)",
      "source": "url"
    }
  ],
  "secretHeaders": ["Authorization", "Cookie"],
  "responseMatches": [
    {
      "type": "jsonPath",
      "value": "$.data.transactions[{{INDEX}}].id",
      "hash": false
    }
  ],
  "responseRedactions": [
    {"jsonPath": "$.data.user.email"}
  ],
  "mobile": {
    "includeAdditionalCookieDomains": [],
    "actionLink": "example://pay?recipient={{RECIPIENT}}&amount={{AMOUNT}}",
    "isExternalLink": true,
    "appStoreLink": "",
    "playStoreLink": ""
  }
}
```

## Parameter selectors
```typescript
interface ParamSelector {
  type: 'jsonPath' | 'regex' | 'xPath';
  value: string;
  source?: 'url' | 'responseBody' | 'responseHeaders' | 'requestHeaders' | 'requestBody';
}
```
- Use JSONPath for JSON responses and XPath for HTML responses.
- For regex selectors, include capture groups `()`.

## Transaction extraction (only for transaction list UI)
### JSON response
```json
{
  "transactionsExtraction": {
    "transactionJsonPathListSelector": "$.data.transactions",
    "transactionJsonPathSelectors": {
      "recipient": "$.target.username",
      "amount": "$.amount",
      "date": "$.created_time",
      "paymentId": "$.id",
      "currency": "$.currency"
    }
  }
}
```

### HTML response
```json
{
  "transactionsExtraction": {
    "transactionXPathListSelector": "//table[@id='transactions']//tr[contains(@class,'row')]",
    "transactionXPathSelectors": {
      "amount": "normalize-space(.//td[contains(@class,'amount')])",
      "recipient": "normalize-space(.//td[contains(@class,'recipient')])",
      "date": "normalize-space(.//td[contains(@class,'date')])",
      "paymentId": "normalize-space(.//@data-payment-id)"
    }
  }
}
```

## Notes
- Use `userInput` when a click is required to load the transaction detail request. The clicked element controls `{{INDEX}}` for selectors.
- Use `shouldReplayRequestInPage: true` when the request must be made in the page context.
- Keep `urlRegex` specific and escaped to avoid false matches.
- Add `responseRedactions` for PII and never include secrets in `responseMatches`.

## Quick test (from docs)
- Run the providers repo (`yarn install`, `yarn start`) and set the extension Base URL to `http://localhost:8080/`.
- Load your template at `http://localhost:8080/{platform}/{provider}.json`.
- Authenticate and then Prove a transaction in `https://developer.zkp2p.xyz/`.
