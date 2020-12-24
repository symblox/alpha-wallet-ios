//
//  AddPopularTokenCoorditor.swift
//  AlphaWallet
//


import UIKit

public class AddPopularTokenCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    private var viewModel: AddPopularTokensViewModel
    private lazy var viewController: AddPopularTokensViewController = .init(
        viewModel: viewModel,
        sessions: sessions,
        assetDefinitionStore: assetDefinitionStore
    )
    private let sessions: ServerDictionary<WalletSession>
    private let filterTokensCoordinator: FilterTokensCoordinator
    private let assetDefinitionStore: AssetDefinitionStore
    private let singleChainTokenCoordinator: SingleChainTokenCoordinator
    private let config: Config

    var coordinators: [Coordinator] = []
//    weak var delegate: AddPopularTokenCoordinatorDelegate?

    init(server: RPCServer, assetDefinitionStore: AssetDefinitionStore, filterTokensCoordinator: FilterTokensCoordinator, tickers: [RPCServer: [AlphaWallet.Address: CoinTicker]], sessions: ServerDictionary<WalletSession>, navigationController: UINavigationController, config: Config, singleChainTokenCoordinator: SingleChainTokenCoordinator) {
        self.config = config
        self.filterTokensCoordinator = filterTokensCoordinator
        self.sessions = sessions
        self.navigationController = navigationController
        self.assetDefinitionStore = assetDefinitionStore
        self.singleChainTokenCoordinator = singleChainTokenCoordinator
        self.viewModel = .init(tokens: singleChainTokenCoordinator.customTokens, network: server, tickers: tickers, filterTokensCoordinator: filterTokensCoordinator)
        viewController.delegate = self
    }

    func start() {
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension AddPopularTokenCoordinator: AddPopularTokensViewControllerDelegate {
    func didSaveSelected(_ viewController: AddPopularTokensViewController, tokens: [ERCToken]) {
        navigationController.popViewController(animated: true)
        singleChainTokenCoordinator.addCustomTokens(tokens)
    }
}
