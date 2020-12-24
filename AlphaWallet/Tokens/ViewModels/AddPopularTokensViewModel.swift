//
//  AddPopularTokensViewModels.swift
//  AlphaWallet

import UIKit

public class AddPopularTokensViewModel {

    private let filterTokensCoordinator: FilterTokensCoordinator
    private var tokens: [ERCToken]
    private var tickers: [RPCServer: [AlphaWallet.Address: CoinTicker]]
    private var network: RPCServer
    var selectedTokens = [ERCToken]()

    var searchText: String? {
        didSet {
        }
    }

    init(tokens: [ERCToken], network: RPCServer, tickers: [RPCServer: [AlphaWallet.Address: CoinTicker]], filterTokensCoordinator: FilterTokensCoordinator) {
        self.tokens = tokens
        self.filterTokensCoordinator = filterTokensCoordinator
        self.tickers = tickers
        self.network = network
    }

    var title: String {
        network.displayName
    }

    var backgroundColor: UIColor {
        GroupedTable.Color.background
    }

    var numberOfSections: Int { 1 }

    func numberOfItems(_ section: Int) -> Int {
        tokens.count
    }

    func item(atIndexPath indexPath: IndexPath) -> ERCToken? {
        return tokens.isEmpty ? nil : tokens[indexPath.row]
    }

    func ticker(for token: ERCToken) -> CoinTicker? {
        return tickers[token.server]?[token.contract]
    }

    func selectIndexPath(_ indexPath: IndexPath) {
        guard let token = self.item(atIndexPath: indexPath) else { return }
        var servers = [ERCToken]()
        if isSelected(token) {
            servers = selectedTokens - [token]
        } else {
            servers = selectedTokens + [token]
        }
        selectedTokens = servers
    }
    
    func isSelected(_ token: ERCToken) -> Bool {
        return selectedTokens.contains(token)
    }

}

extension ERCToken: Equatable {

    static func ==(lhs: ERCToken, rhs: ERCToken) -> Bool {
        lhs.contract.sameContract(as: rhs.contract)
    }
}

