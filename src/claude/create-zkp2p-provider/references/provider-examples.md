# Provider Template Examples (from the public providers repo)

These are trimmed examples from current public templates. Use them as patterns, not as copy-paste solutions.

## Wise: list endpoint + detail endpoint + mobile login
Source shape: `wise/transfer_wise.json`

```json
{
  "actionType": "transfer_wise",
  "authLink": "https://wise.com/all-transactions?direction=OUTGOING",
  "url": "https://wise.com/gateway/v3/profiles/{{PROFILE_ID}}/transfers/{{TRANSACTION_ID}}",
  "metadata": {
    "platform": "wise",
    "urlRegex": "https://wise.com/gateway/v1/profiles/\\S+/activities/list",
    "transactionsExtraction": {
      "transactionJsonPathListSelector": "$",
      "transactionJsonPathSelectors": {
        "amount": "$.primaryAmount",
        "paymentId": "$.resource.id",
        "recipient": "$.title",
        "date": "$.visibleOn",
        "currency": "$.currency"
      }
    }
  },
  "paramNames": ["TRANSACTION_ID", "PROFILE_ID"],
  "mobile": {
    "useExternalAction": true,
    "external": {
      "actionLink": "transferwise://pay/me/{{RECIPIENT_ID}}"
    },
    "login": {
      "usernameSelector": "#email, input[name=\"email\"][type=\"email\"]",
      "passwordSelector": "#password, input[name=\"password\"][type=\"password\"]"
    }
  }
}
```

Notes:
- The list response and proof response are different endpoints.
- The mobile block uses the current nested shape (`mobile.external`, `mobile.login`).

## Luxon: metadataUrl for list replay
Source shape: `luxon/transfer_luxon.json`

```json
{
  "actionType": "transfer_luxon",
  "url": "https://client-service.luxon.com/api/v4/transfers/{{TRANSFER_ID}}",
  "metadata": {
    "metadataUrl": "https://client-service.luxon.com/api/v4/transfers?page=0&size=10",
    "metadataUrlMethod": "GET",
    "platform": "luxon",
    "urlRegex": "https://client-service.luxon.com/api/v4/transfers\\S+",
    "transactionsExtraction": {
      "transactionJsonPathListSelector": "$.content",
      "transactionJsonPathSelectors": {
        "recipient": "$.receiver.label",
        "amount": "$.receiver.value.amount",
        "date": "$.createdAt",
        "paymentId": "$.transferId",
        "currency": "$.receiver.value.currency",
        "status": "$.status"
      }
    }
  }
}
```

Notes:
- `metadataUrl` is useful when the selection list is not the same as the final proof URL.
- Keep `metadataUrl` same-host and `https`.

## Chase Zelle: additionalProofs for recipient detail
Source shape: `chase/transfer_zelle.json`

```json
{
  "actionType": "transfer_zelle",
  "url": "https://secure.chase.com/svc/rr/payments/secure/v1/quickpay/payment/activity/list",
  "metadata": {
    "platform": "zelle",
    "transactionsExtraction": {
      "transactionJsonPathListSelector": "$.listItems",
      "transactionJsonPathSelectors": {
        "amount": "$.amount",
        "paymentId": "$.id",
        "recipient": "$.recipientName",
        "date": "$.date",
        "currency": "$.currency"
      }
    }
  },
  "additionalProofs": [
    {
      "url": "https://secure.chase.com/svc/rr/payments/secure/v1/quickpay/payment/activity/detail/list",
      "method": "POST",
      "body": "paymentId={{PAYMENT_ID}}",
      "paramNames": ["PAYMENT_ID"],
      "paramSelectors": [
        { "type": "jsonPath", "value": "$.listItems[{{INDEX}}].id" }
      ],
      "responseMatches": [
        { "type": "regex", "value": "\"recipientEmail\":\"(?<recipientEmail>[^\"]+)\"" }
      ]
    }
  ]
}
```

Notes:
- The first proof establishes the payment row.
- The second proof binds recipient identity details that do not live on the list endpoint.

## N26 and similar extension-oriented click flows
Source shape: `n26/transfer_n26.json`

```json
{
  "metadata": {
    "shouldReplayRequestInPage": true,
    "userInput": {
      "promptText": "Select a transfer below to proceed with authentication",
      "transactionXpath": "//section[@id='feed-pending-module']//div[contains(@class,'row')]"
    }
  }
}
```

Notes:
- `metadata.userInput` and `metadata.shouldReplayRequestInPage` are useful for click-driven, in-page flows.
- Treat these as compatibility fields and verify that the target runtime actually uses them.

## Mobile-specific patterns worth copying

Public templates commonly use:
- `mobile.useExternalAction`
- `mobile.external.actionLink`
- `mobile.userAgent`
- `mobile.login`
- `mobile.additionalClientOptions.cipherSuites`

Prefer copying the shape from a current public provider that is closest to your target platform instead of inventing a new mobile layout.
