//
//  CoinsController.swift
//  CryptoTracker
//
//  Created by Gaganjot Singh on 2/18/24.
//

import Combine
import Foundation
import UIKit

class CoinsController: UICollectionViewController {
    let coinCell = "CoinCell"
    private var coins = [Coin]() {
        didSet {
            collectionView.reloadData()
        }
    }

    private let viewModel = CoinViewModel()
    private var cancellables = Set<AnyCancellable>()

    let loader: UIActivityIndicatorView = {
        var loader = UIActivityIndicatorView(style: .large)
        loader.color = .secondaryLabel
        loader.startAnimating()
        loader.hidesWhenStopped = true
        return loader
    }()

    let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    init() {
        let layout = UICollectionViewCompositionalLayout(section: Layouts.shared.coinSection())
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        configCollectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCoins()
    }

    private func configCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CoinListCell.self, forCellWithReuseIdentifier: coinCell)
        view.addSubview(loader)
        view.addSubview(label)
        loader.fillSuperview()
        label.fillSuperview()
    }

    private func fetchCoins() {
        viewModel.fetchCoins()
            .sink {
                [weak self] completion in
                switch completion {
                case let .success(coins):
                    self?.coins = coins

                case let .failed(error):
                    self?.label.text = error.localizedDescription
                case let .loading(loading):
                    loading ? self?.loader.startAnimating() : self?.loader.stopAnimating()
                    if loading == false {
                        self?.label.isHidden = false
                        self?.loader.isHidden = true
                    }
                }
            }
            .store(in: &cancellables)
    }

    override func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let VC = CoinDetailsController()
        VC.data = coins[indexPath.row]
        navigationController?.pushViewController(VC, animated: true)
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        coins.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: coinCell, for: indexPath) as! CoinListCell
        cell.data = coins[indexPath.row]
        return cell
    }
}
