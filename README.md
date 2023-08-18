# BTSECryptoMarketList

## Special Note

### The code is development on macOS Ventura, Xcode 14.3.1, CocoaPod 1.12.1 and test on iOS 16.4

## List Crypto Market List Price Feature Specs

### Story: User request to see the crypto market list and it's price

### Type#1

```
As an online user
I want the app to show crypto market list and their prices
So I can see check the crypto market price I care about.
```

#### Acceptance criteria

```
Given the user has connectivity
When the user requests to see the crypto market list and their prices
Then the app should display the crypto market list and their price
```

## Use Cases

### Load crypto market list from remote use case

#### Data:
- URL

#### Primary path:
1. Execute "Load Crypto Market List" command.
2. System download data from the URL.
3. System validate downloaded data.
4. System create crypto market list from valid data.
5. System delivers crypto market list

#### Invalid data error path:
1. System delivers invalid data error.

#### No connectivity error path:
1. System delivers connectivity error.

---

### Receive crypto market price from remote use case

#### Data:
- Websocket URL

#### Primary path:
1. Execute "Open" command.
2. System open websocket connection to the URL.
3. Execute "Subscribe" command.
4. System send subscribe message to server.
6. System delivers received crypto market price

#### Receive close message path:
1. System delivers connectivity error.

#### Receive error message path:
1. System delivers error.

#### Receive invalid data path:
1. System filter out the data.

#### Subscribe error path:
1. System delivers connectivity error.

#### Open error path:
1. System delivers connectivity error.

---

## Model Specs

### Market


| property | type   |
|----------|--------|
| symbol   | String |
| future   | Bool   |
 

### Payload contract

```
https://api.btse.com/futures/api/inquire/initial/market

GET

200 RESPONSE

{
   "code":1,
   "msg":"success",
   "time":1692110797804,
   "data":[
      {
         "marketName":"CYBER-USD",
         "active":true,
         "marketClosed":false,
         "matchingDisabled":false,
         "future":false,
         "timeBasedContract":false,
         "openTime":0,
         "closeTime":0,
         "startMatching":0,
         "inactiveTime":0,
         "sortId":0,
         "lastUpdate":null,
         "symbol":"CYBER",
         "quoteCurrency":"USD",
         "baseCurrency":"CYBER",
         "fundingRate":0.0,
         "openInterest":0.0,
         "openInterestUSD":0.0,
         "display":false,
         "displayQuote":null,
         "globalDisplayQuote":null,
         "displayOrder":null,
         "isFavorite":false,
         "availableQuotes":[
            {
               "id":4,
               "sortId":1,
               "name":"US Dollar",
               "shortName":"USD",
               "symbol":"$",
               "type":1,
               "status":1,
               "gmtCreate":1517909896000,
               "gmtModified":1517909898000,
               "decimals":4,
               "isDefault":1,
               "minSize":0.01,
               "maxSize":1000000.0,
               "increment":0.01,
               "isSettlement":1,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180827653657.png",
               "fiat":true,
               "crypto":false,
               "typeEnum":"Fiat"
            },
            {
               "id":97,
               "sortId":55,
               "name":"USD Coin",
               "shortName":"USDC",
               "symbol":"USDC",
               "type":2,
               "status":1,
               "gmtCreate":1562753917523,
               "gmtModified":null,
               "decimals":6,
               "isDefault":null,
               "minSize":1.0E-5,
               "maxSize":20000.0,
               "increment":0.0,
               "isSettlement":0,
               "depositMin":0.0,
               "isStable":true,
               "isQuote":false,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":null,
               "fiat":false,
               "crypto":true,
               "typeEnum":"Crypto"
            },
            {
               "id":79,
               "sortId":53,
               "name":"Tether USD",
               "shortName":"USDT",
               "symbol":"₮",
               "type":2,
               "status":1,
               "gmtCreate":1534768098032,
               "gmtModified":null,
               "decimals":4,
               "isDefault":0,
               "minSize":10.0,
               "maxSize":1000000.0,
               "increment":1.0E-6,
               "isSettlement":0,
               "depositMin":0.0,
               "isStable":true,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "listedAsSpotQuote":true,
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180904005430.png",
               "fiat":false,
               "crypto":true,
               "typeEnum":"Crypto"
            },
            {
               "id":2,
               "sortId":51,
               "name":"Bitcoin",
               "shortName":"BTC",
               "symbol":"BTC",
               "type":2,
               "status":1,
               "gmtCreate":1516123349000,
               "gmtModified":1540793275542,
               "decimals":4,
               "isDefault":0,
               "minSize":0.002,
               "maxSize":2000.0,
               "increment":1.0E-5,
               "isSettlement":0,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180827224655.png",
               "fiat":false,
               "crypto":true,
               "typeEnum":"Crypto"
            },
            {
               "id":1,
               "sortId":52,
               "name":"Ethereum",
               "shortName":"ETH",
               "symbol":"ETH",
               "type":2,
               "status":1,
               "gmtCreate":1516112883000,
               "gmtModified":1520939365000,
               "decimals":4,
               "isDefault":0,
               "minSize":1.0E-5,
               "maxSize":5000.0,
               "increment":1.0E-5,
               "isSettlement":0,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180827654463.png",
               "fiat":false,
               "crypto":true,
               "typeEnum":"Crypto"
            }
         ],
         "initialMarginPercentage":0.0,
         "maintenanceMarginPercentage":0.0,
         "prediction":false,
         "favorite":false
      },
      {
         "marketName":"BTSE-USD",
         "active":true,
         "marketClosed":false,
         "matchingDisabled":false,
         "future":false,
         "timeBasedContract":false,
         "openTime":0,
         "closeTime":0,
         "startMatching":0,
         "inactiveTime":0,
         "sortId":0,
         "lastUpdate":null,
         "symbol":"BTSE",
         "quoteCurrency":"USD",
         "baseCurrency":"BTSE",
         "fundingRate":0.0,
         "openInterest":0.0,
         "openInterestUSD":0.0,
         "display":true,
         "displayQuote":null,
         "globalDisplayQuote":null,
         "displayOrder":0,
         "isFavorite":true,
         "availableQuotes":[
            {
               "id":4,
               "sortId":1,
               "name":"US Dollar",
               "shortName":"USD",
               "symbol":"$",
               "type":1,
               "status":1,
               "gmtCreate":1517909896000,
               "gmtModified":1517909898000,
               "decimals":4,
               "isDefault":1,
               "minSize":0.01,
               "maxSize":1000000.0,
               "increment":0.01,
               "isSettlement":1,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180827653657.png",
               "fiat":true,
               "crypto":false,
               "typeEnum":"Fiat"
            },
            {
               "id":80,
               "sortId":2,
               "name":"Euro",
               "shortName":"EUR",
               "symbol":"€",
               "type":1,
               "status":1,
               "gmtCreate":1536066023572,
               "gmtModified":null,
               "decimals":4,
               "isDefault":0,
               "minSize":0.0,
               "maxSize":1000000.0,
               "increment":0.01,
               "isSettlement":1,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180904456422.png",
               "fiat":true,
               "crypto":false,
               "typeEnum":"Fiat"
            },
            {
               "id":81,
               "sortId":3,
               "name":"Great Britain Pound",
               "shortName":"GBP",
               "symbol":"£",
               "type":1,
               "status":1,
               "gmtCreate":1536066151921,
               "gmtModified":null,
               "decimals":4,
               "isDefault":0,
               "minSize":0.0,
               "maxSize":1000000.0,
               "increment":0.01,
               "isSettlement":1,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180904271975.png",
               "fiat":true,
               "crypto":false,
               "typeEnum":"Fiat"
            },
            {
               "id":78,
               "sortId":10,
               "name":"Japanese Yen",
               "shortName":"JPY",
               "symbol":"￥",
               "type":1,
               "status":1,
               "gmtCreate":1534767981433,
               "gmtModified":null,
               "decimals":4,
               "isDefault":0,
               "minSize":0.01,
               "maxSize":1000000.0,
               "increment":0.01,
               "isSettlement":1,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180831399263.png",
               "fiat":true,
               "crypto":false,
               "typeEnum":"Fiat"
            },
            {
               "id":83,
               "sortId":5,
               "name":"Singapore Dollar",
               "shortName":"SGD",
               "symbol":"S$",
               "type":1,
               "status":1,
               "gmtCreate":1536066286733,
               "gmtModified":null,
               "decimals":4,
               "isDefault":0,
               "minSize":0.0,
               "maxSize":1000000.0,
               "increment":0.01,
               "isSettlement":1,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180904787406.png",
               "fiat":true,
               "crypto":false,
               "typeEnum":"Fiat"
            },
            {
               "id":2,
               "sortId":51,
               "name":"Bitcoin",
               "shortName":"BTC",
               "symbol":"BTC",
               "type":2,
               "status":1,
               "gmtCreate":1516123349000,
               "gmtModified":1540793275542,
               "decimals":4,
               "isDefault":0,
               "minSize":0.002,
               "maxSize":2000.0,
               "increment":1.0E-5,
               "isSettlement":0,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180827224655.png",
               "fiat":false,
               "crypto":true,
               "typeEnum":"Crypto"
            },
            {
               "id":1,
               "sortId":52,
               "name":"Ethereum",
               "shortName":"ETH",
               "symbol":"ETH",
               "type":2,
               "status":1,
               "gmtCreate":1516112883000,
               "gmtModified":1520939365000,
               "decimals":4,
               "isDefault":0,
               "minSize":1.0E-5,
               "maxSize":5000.0,
               "increment":1.0E-5,
               "isSettlement":0,
               "depositMin":0.0,
               "isStable":false,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180827654463.png",
               "fiat":false,
               "crypto":true,
               "typeEnum":"Crypto"
            },
            {
               "id":79,
               "sortId":53,
               "name":"Tether USD",
               "shortName":"USDT",
               "symbol":"₮",
               "type":2,
               "status":1,
               "gmtCreate":1534768098032,
               "gmtModified":null,
               "decimals":4,
               "isDefault":0,
               "minSize":10.0,
               "maxSize":1000000.0,
               "increment":1.0E-6,
               "isSettlement":0,
               "depositMin":0.0,
               "isStable":true,
               "isQuote":true,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "listedAsSpotQuote":true,
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":"20180904005430.png",
               "fiat":false,
               "crypto":true,
               "typeEnum":"Crypto"
            },
            {
               "id":97,
               "sortId":55,
               "name":"USD Coin",
               "shortName":"USDC",
               "symbol":"USDC",
               "type":2,
               "status":1,
               "gmtCreate":1562753917523,
               "gmtModified":null,
               "decimals":6,
               "isDefault":null,
               "minSize":1.0E-5,
               "maxSize":20000.0,
               "increment":0.0,
               "isSettlement":0,
               "depositMin":0.0,
               "isStable":true,
               "isQuote":false,
               "isSupportAddressExtension":false,
               "currencyUnitMultiplier":null,
               "coinFuncSwitch":{
                  "walletDeposit":true,
                  "walletWithdraw":true,
                  "walletTransferToUser":true,
                  "walletConvert":true,
                  "walletConvertFrom":true,
                  "walletTransferToFutures":true,
                  "walletOtc":true
               },
               "logo":null,
               "fiat":false,
               "crypto":true,
               "typeEnum":"Crypto"
            }
         ],
         "initialMarginPercentage":0.0,
         "maintenanceMarginPercentage":0.0,
         "prediction":false,
         "favorite":true
      }
   ],
   "success":true
}
```

---

### Price


### Payload contract

```
{ "topic": "coinIndex",
  "id": null,
  "data": {
           "ANT_1": {
                      "id": "ANT",
                      "name": "ANT",
                      "type: 1,
                      "price": 3.273782
                    }
          }
}              

```





