//
//  VelasTokensViewModel.swift
//  AlphaWallet

import Foundation

class VelasTokensViewModel: TokensViewModel {
    
    var groupToken = [RPCServer: [TokenObject]]()
    
    override var filter: WalletFilter {
        didSet {
            super.filter = filter
            groupToken = groupFilteredTokens()
        }
    }
    
    func showAsGroup() -> Bool {
        return !groupToken.isEmpty
    }
    
    override func numberOfGroup() -> Int {
        return showAsGroup() ? groupToken.count : 1
    }
    
    override func numberItemsOfGroup(_ group: Int) -> Int {
        guard showAsGroup() else {
            return numberOfItems()
        }
        let groupKey = ([RPCServer](groupToken.keys)).sorted { $0.displayOrderPriority < $1.displayOrderPriority }
        return (!groupKey.isEmpty && groupKey.count > group) ? (groupToken[groupKey[group]]?.count ?? 0 ) : 0
    }

    override func item(for row: Int, section: Int) -> TokenObject {
        if showAsGroup() {
            let groupKey = ([RPCServer](groupToken.keys)).sorted { $0.displayOrderPriority < $1.displayOrderPriority }
            if let token = groupToken[groupKey[section]]?[row] {
                return token
            }
        }
        return filteredTokens[row]
    }

    private func groupFilteredTokens() -> [RPCServer: [TokenObject]] {
        var result = [RPCServer: [TokenObject]]()
        for token in filteredTokens {
            if !result.keys.contains(token.server) {
                result[token.server] = [TokenObject]()
            }
            result[token.server]?.append(token)
        }
        return result
    }
    
}
