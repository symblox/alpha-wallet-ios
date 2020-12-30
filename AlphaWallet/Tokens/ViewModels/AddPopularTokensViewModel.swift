//
//  AddPopularTokensViewModels.swift
//  AlphaWallet

import UIKit

public class AddPopularTokensViewModel {

    private let filterTokensCoordinator: FilterTokensCoordinator
    private var tokens: [ERCToken]
    private var displayedTokens = [ERCToken]()
    private var tickers: [RPCServer: [AlphaWallet.Address: CoinTicker]]
    private var network: RPCServer
    var selectedTokens = [ERCToken]()

    var searchText: String? {
        didSet {
            filterTokens(tokens)
        }
    }

    init(tokens: [ERCToken], network: RPCServer, tickers: [RPCServer: [AlphaWallet.Address: CoinTicker]], filterTokensCoordinator: FilterTokensCoordinator) {
        self.tokens = tokens
        self.filterTokensCoordinator = filterTokensCoordinator
        self.tickers = tickers
        self.network = network
        filterTokens(tokens)
    }

    var title: String {
        network.name
    }

    var backgroundColor: UIColor {
        GroupedTable.Color.background
    }

    var numberOfSections: Int { 1 }

    func numberOfItems(_ section: Int) -> Int {
        displayedTokens.count
    }

    func item(atIndexPath indexPath: IndexPath) -> ERCToken? {
        return displayedTokens.isEmpty ? nil : displayedTokens[indexPath.row]
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

    private func filterTokens(_ tokens:[ERCToken]) {
        displayedTokens.removeAll()
        if !(searchText ?? "").isEmpty {
            let searchLowCases = searchText!.lowercased()
            for token in tokens {
                if token.name.lowercased().contains(searchLowCases) {
                    displayedTokens.append(token)
                }
            }
        } else {
            displayedTokens.append(contentsOf: tokens)
        }
    }
}

extension ERCToken: Equatable {

    static func ==(lhs: ERCToken, rhs: ERCToken) -> Bool {
        lhs.contract.sameContract(as: rhs.contract)
    }
}

