//
//  VelasTokensViewModel.swift
//  AlphaWallet

import UIKit

class VelasTokensViewModel: TokensViewModel {
    
    var servers = [ServerGroup]()
    var groupToken = [ServerGroup: [TokenObject]]()
    var config: Config?
    
    override var filter: WalletFilter {
        didSet {
            super.filter = filter
            groupToken = groupFilteredTokens()
        }
    }
    
    override func numberOfGroup() -> Int {
        return groupToken.count
    }
    
    override func numberItemsOfGroup(_ section: Int) -> Int {
        guard numberOfGroup() > 0 else {
            return numberOfItems()
        }
        let groupKeys = sortedServers()
        let groupId = groupKeys[section]
        return groupToken[groupId]?.count ?? 0
    }

    override func item(for row: Int, section: Int) -> TokenObject {
        if numberOfGroup() > 0 {
            let groupId = servers[section]
            if let token = groupToken[groupId]?[row] {
                return token
            }
        }
        return filteredTokens[row]
    }
    
    override func markTokenHidden(token: TokenObject) -> Bool {
        let didRemoveSuper = super.markTokenHidden(token: token)
        if didRemoveSuper {
            groupToken.removeAll()
            servers.removeAll()
            groupToken = groupFilteredTokens()
        }
        return didRemoveSuper
    }
    
    func serverForSection(_ section: Int) -> RPCServer? {
        let groupServer = servers[section]
        switch groupServer {
        case .Main:
            return .main
        case .Velas:
            return config?.enabledServers.first { $0.isVelasCase }
        case .Binance: return RPCServer.binance_smart_chain
        case .Heco: return RPCServer.heco
        default:
            return nil
        }
    }
    
    private func sortedServers() -> [ServerGroup] {
        return servers.sorted(by: {group1, group2 in
            return group1.order < group2.order
        })
    }

    private func groupFilteredTokens() -> [ServerGroup: [TokenObject]] {
        var result = [ServerGroup: [TokenObject]]()
        for token in filteredTokens {
            let networkId = groupIdForNetwork(token.server)
            if !result.keys.contains(networkId) {
                servers.append(networkId)
                result[networkId] = [TokenObject]()
            }
            result[networkId]?.append(token)
        }
        servers = sortedServers()
        return result
    }

    private func groupIdForNetwork(_ network: RPCServer) -> ServerGroup {
        if network.isVelasCase {
            return .Velas(.velas)
        }
        
        switch network {
        case .main:
            return ServerGroup.Main
        case .heco:
            return ServerGroup.Heco
        case .binance_smart_chain:
            return ServerGroup.Binance
        default:
            return .Other
        }
    
    }
    
}

enum ServerGroup: Hashable {
    case Velas(RPCServer)
    case Main
    case Other
    case Heco
    case Binance

    var order: Int {
        switch self {
        case .Velas: return 1
        case .Main: return 2
        case .Heco: return 3
        case .Binance: return 4
        case .Other:
            return 100
        }
    }
}
