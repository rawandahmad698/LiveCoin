
## CoinLive
Realtime BTC data using RxSwift and URLSession

<p align="center">
  <img src="https://media.discordapp.net/attachments/1078995180759285763/1141018335564279878/image.png?width=1696&height=1260">
</p>

#### External frameworks used: 
- RxSwift

#### To turn off the console logs use: 
```swift
URLSession.rx.shouldLogRequest = { request in 
   return false // Or use request to determine if you want to log or not
}
```
