//
//  APIService.swift
//  CryptoTracker
//
//  Created by Gaganjot Singh on 2/18/24.
//

import Combine
import Foundation

class APIService {
    static let shared = APIService()
    private var cancellables = Set<AnyCancellable>()
    let headers: [String: String] = ["Accepts": "application/json",
                                     "X-CMC_PRO_API_KEY": APIKey]

    var urlComponent = URLComponents()

    // Returns AnyPublisher
    func getCoins() -> AnyPublisher<Coins, Error> {
        urlComponent.scheme = "https"
        urlComponent.host = "pro-api.coinmarketcap.com"
        urlComponent.path = "/v1/cryptocurrency/listings/latest"
        urlComponent.queryItems = [
            URLQueryItem(name: "start", value: "1"),
            URLQueryItem(name: "limit", value: "15"),
            URLQueryItem(name: "convert", value: "USD"),
        ]

        var urlRequest = URLRequest(url: urlComponent.url!)
        urlRequest.allHTTPHeaderFields = headers

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .catch { error in
                Fail(error: error).eraseToAnyPublisher()
            }
            .tryMap { data, _ in
                data
            }
            .decode(type: Coins.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getCoin(id: String) -> AnyPublisher<CoinsDetail, Error> {
        urlComponent.scheme = "https"
        urlComponent.host = "pro-api.coinmarketcap.com"
        urlComponent.path = "/v2/cryptocurrency/info"
        urlComponent.queryItems = [
            URLQueryItem(name: "start", value: "1"),
            URLQueryItem(name: "limit", value: "15"),
            URLQueryItem(name: "convert", value: "USD"),
        ]

        urlComponent.queryItems = [
            URLQueryItem(name: "id", value: id),
        ]

        var urlRequest = URLRequest(url: urlComponent.url!)
        urlRequest.allHTTPHeaderFields = headers

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .catch { error in
                Fail(error: error).eraseToAnyPublisher()
            }
            .tryMap { data, _ in
                data
            }
            .decode(type: CoinsDetail.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
