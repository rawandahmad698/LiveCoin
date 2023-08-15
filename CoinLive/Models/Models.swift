//
//  Models.swift
//  CoinLive
//
//  Created by Rawand Ahmad on 15/08/2023.
//

import UIKit
import RxSwift
import RxCocoa

struct ApiResponse: Codable {
    let currentBTC: Double
    let currentBTCHigh: Double
    let currentBTCLow: Double
    
    enum CodingKeys: String, CodingKey {
        case currentBTC = "current_BTC"
        case currentBTCHigh = "current_BTC_high"
        case currentBTCLow = "current_BTC_low"
    }
}

class CryptoViewModel {
    private let disposeBag = DisposeBag()
    
    let cryptoData: BehaviorSubject<ApiResponse?> = BehaviorSubject(value: nil)
    let errorMessage: PublishSubject<String> = PublishSubject()
    
    init() {
        Observable<Int>.interval(.milliseconds(1000), scheduler: MainScheduler.instance)
            .flatMapLatest { _ in
                self.fetchCryptoData()
            }
            .subscribe(onNext: { response in
                self.cryptoData.onNext(response)
            }, onError: { error in
                if let error = error as? URLError {
                    self.handleURLError(error)
                } else {
                    self.errorMessage.onNext("An unknown error occurred.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchCryptoData() -> Observable<ApiResponse?> {
        guard let url = URL(string: "https://coinlayer.com/coin_api.php") else {
            return Observable.just(nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let headers = [
            "Accept": "application/json, text/javascript, */*; q=0.01",
            "Sec-Fetch-Site": "same-origin",
            "Accept-Language": "en-GB,en-US;q=0.9,en;q=0.8",
            "Sec-Fetch-Mode": "cors",
            "Host": "coinlayer.com",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15",
            "Connection": "keep-alive",
            "Referer": "https://coinlayer.com/",
            "Sec-Fetch-Dest": "empty",
            "X-Requested-With": "XMLHttpRequest",
            "Cache-Control": "no-cache"
        ]
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return URLSession.shared.rx.response(request: request)
            .map { (response, data) -> ApiResponse? in
                if response.statusCode >= 400 {
                    self.handleHTTPError(response.statusCode)
                    return nil
                }
                
                let decoder = JSONDecoder()
                return try? decoder.decode(ApiResponse.self, from: data)
            }
            .catch { error in
                if let urlError = error as? URLError {
                    if urlError.code == .cancelled {
                        self.errorMessage.onNext("Request was cancelled.")
                    } else {
                        self.errorMessage.onNext("An error occurred while decoding crypto data.")
                    }
                } else {
                    self.errorMessage.onNext("An unknown error occurred.")
                }
                return Observable.just(nil)
            }
    }
    
    private func handleHTTPError(_ statusCode: Int) {
        switch statusCode {
        case 400:
            errorMessage.onNext("Bad Request")
        case 401:
            errorMessage.onNext("Unauthorized")
        case 404:
            errorMessage.onNext("Not Found")
        default:
            errorMessage.onNext("HTTP Error \(statusCode)")
        }
    }
    
    private func handleURLError(_ error: URLError) {
        errorMessage.onNext("URL Error: \(error.localizedDescription)")
    }
}
