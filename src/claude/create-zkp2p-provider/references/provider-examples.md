# Provider Template Examples (from zkp2p/providers)

These are trimmed examples pulled from the public providers repo to show real-world patterns. Use them as inspiration, not as drop-in templates. Paths below refer to the providers repo layout.

## Venmo (JSON list + regex matches + mobile login)
Source: `venmo/transfer_venmo.json`

```json
{
  "actionType": "transfer_venmo",
  "proofEngine": "reclaim",
  "authLink": "https://account.venmo.com/?feed=mine",
  "url": "https://account.venmo.com/api/stories?feedType=me&externalId={{SENDER_ID}}",
  "method": "GET",
  "metadata": {
    "platform": "venmo",
    "urlRegex": "https://account.venmo.com/api/stories\\?feedType=me&externalId=\\S+",
    "transactionsExtraction": {
      "transactionJsonPathListSelector": "$.stories",
      "transactionJsonPathSelectors": {
        "recipient": "$.title.receiver.username",
        "amount": "$.amount",
        "date": "$.date",
        "paymentId": "$.paymentId",
        "currency": "$.currency"
      }
    }
  },
  "paramNames": ["SENDER_ID"],
  "paramSelectors": [
    {"type": "jsonPath", "value": "$.stories[{{INDEX}}].title.sender.id"}
  ],
  "responseMatches": [
    {"type": "regex", "value": "\"amount\":\"- \\$(?<amount>[^\"]+)\""}
  ]
}
```
Notes:
- Uses JSONPath extraction for list views.
- Regex responseMatches bind proof values; use single-escaped patterns.
- Full file includes mobile login selectors and response redactions.

## N26 (GraphQL POST + replay in page + userInput)
Source: `n26/transfer_n26.json`

```json
{
  "actionType": "transfer_n26",
  "proofEngine": "reclaim",
  "authLink": "https://app.n26.com/",
  "url": "https://app.n26.com/graphql?op=getFeedTransactionQuery",
  "method": "POST",
  "body": "{{BODY}}",
  "metadata": {
    "shouldReplayRequestInPage": true,
    "platform": "n26",
    "urlRegex": "https://app.n26.com/graphql\\?op=getFeedTransactionQuery",
    "method": "POST",
    "userInput": {
      "promptText": "Select a transfer below to proceed with authentication",
      "transactionXpath": "//section[@id='feed-pending-module']//div[contains(@class,'q1hbnk3w') and contains(@class,'q1hbnk5w')]"
    },
    "transactionsExtraction": {
      "transactionJsonPathSelectors": {
        "recipient": "$.data.transaction.containers[0].body[0].title",
        "amount": "$.data.transaction.containers[0].body[0].amount.money.unscaledAmount",
        "date": "$.data.transaction.containers[0].body[0].subtitle",
        "paymentId": "$.data.transaction.containers[1].body[1].action.tracking.property",
        "currency": "$.data.transaction.containers[0].body[0].amount.money.currency.code"
      }
    }
  },
  "paramNames": ["BODY"],
  "paramSelectors": [
    {"type": "regex", "value": "^(.*)$", "source": "requestBody"}
  ]
}
```
Notes:
- Uses page replay for GraphQL calls and a click-driven userInput.
- Extracts the request body as a parameter.

## PayPal (HTML response + preprocessRegex)
Source: `paypal/transfer_paypal.json`

```json
{
  "actionType": "transfer_paypal",
  "proofEngine": "reclaim",
  "authLink": "https://www.paypal.com/myaccount/activities/filter/?q=...",
  "url": "https://www.paypal.com/myaccount/activities/details/inline/{{PAYMENT_ID}}",
  "method": "GET",
  "metadata": {
    "platform": "paypal",
    "urlRegex": "^https://www.paypal.com/myaccount/activities/filter/\\?q=.*$",
    "method": "GET",
    "preprocessRegex": "<pre[^>]*>([\\s\\S]*?)<\\/pre>",
    "transactionsExtraction": {
      "transactionJsonPathListSelector": "$.data.data.activity.transactions",
      "transactionJsonPathSelectors": {
        "recipient": "$.ftsSearchInfo.email",
        "amount": "$.ftsSearchInfo.displayAmount",
        "date": "$.date.rawDate.date",
        "paymentId": "$.id",
        "currency": "$.amounts.currencyCode"
      }
    }
  },
  "paramNames": ["PAYMENT_ID"],
  "paramSelectors": [
    {"type": "jsonPath", "value": "$.data.data.activity.transactions[{{INDEX}}].id"}
  ]
}
```
Notes:
- Uses preprocessRegex to extract embedded JSON from HTML.
- Pulls a list then selects a transaction by index.
