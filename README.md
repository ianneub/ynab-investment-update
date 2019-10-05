# YNAB BTC Update

This app will update a transaction in YNAB for the current month with the difference in value between the previous month and the current portfolio value.

If there is no transaction for the current month in YNAB, it will create a new transaction.

After running this script the balance in YNAB should equal the portfolio value.

## ENV Vars

You must set the following env vars.

* COINMARKETCAP_KEY

* YNAB_API_KEY
* YNAB_BUDGET_ID
* YNAB_ACCOUNT_ID
* YNAB_PAYEE_ID

* YNAB_STOCK_ACCOUNT_ID

### Stock/Crypto settings

These env vars need a specific pattern with pairs of `symbols:qty` separated by `;`. For example: `BTC:0.015;ETH:12.5866` or `VTI:15.123;BND:120.0`. `STOCKS` can also have a special symbol named `CASH` that will simply be added to the total and not looked up.

* STOCKS
* CRYPTOS

