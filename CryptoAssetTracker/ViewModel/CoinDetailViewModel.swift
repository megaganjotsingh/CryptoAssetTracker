//
//  CoinDetailViewModel.swift
//  CryptoTracker
//
//  Created by Gaganjot Singh on 2/21/24.
//

import Combine
import Foundation

class CoinDetailViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    enum FetchResult {
        case failed(error: Error)
        case success(coin: CoinDetail)
        case loading(loading: Bool)
    }

    private let fetchResult: PassthroughSubject<FetchResult, Never> = .init()

    func fetchCoin(id: String) -> AnyPublisher<FetchResult, Never> {
        APIService.shared.getCoin(id: id).sink { [weak self] completion in
            self?.fetchResult.send(.loading(loading: false))
            switch completion {
            case let .failure(error):
                self?.fetchResult.send(.failed(error: error))
                print("Error is \(error.localizedDescription)")
            case .finished:
                print("Finished")
            }
        } receiveValue: { [weak self] coinDetails in
            print(coinDetails)
            self?.fetchResult.send(.success(coin: coinDetails.data[id]!))
        }.store(in: &cancellables)
        return fetchResult.eraseToAnyPublisher()
    }
}
