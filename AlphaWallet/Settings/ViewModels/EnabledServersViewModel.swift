// Copyright © 2018 Stormbird PTE. LTD.

import Foundation

struct EnabledServersViewModel {

    var servers: [RPCServer]
    var selectedServers: [RPCServer]

    private var dicServers: [Int: [RPCServer]]?
    private var keys = [-1]
    
    init(servers: [RPCServer], selectedServers: [RPCServer]) {
        self.servers = servers
        self.selectedServers = selectedServers
        self.dicServers = groupServer()
        keys = (dicServers?.keys.map{$0} ?? [-1]).sorted{$0 > $1}
    }
    
    var title: String {
        return R.string.localizable.settingsEnabledNetworksButtonTitle()
    }

    func server(for indexPath: IndexPath) -> RPCServer {
        if dicServers != nil {
            let key = keys[indexPath.section]
            if let item = dicServers?[key]?[indexPath.row] {
                return item
            }
        }
        return servers[indexPath.row]
    }
    
    func isServerSelected(_ server: RPCServer) -> Bool {
        return selectedServers.contains(server)
    }
    
    func nameSection(_ section: Int) -> String? {
        return section == 0 ? RPCServer.velas.name : "Others"
    }
    
    func numberItemSection(_ section: Int) -> Int {
        return dicServers?[keys[section]]?.count ?? servers.count
    }
    
    func numberOfGroup() -> Int {
        return !keys.isEmpty ? keys.count : 0
    }
    
    func getSingleSelectionKey() -> [Int] {
        return keys.filter{$0 != -1}
    }
    
    private func sortServer(_ server1: RPCServer, _ server2: RPCServer) -> Bool {
        return server1.chainID == server1.chainID ? server1.name > server1.name : server1.chainID > server1.chainID
    }
    
    private func groupServer() -> [Int: [RPCServer]]? {
        let sorteds = servers.sorted{sortServer($0, $1)}
        var groupServers : [Int: [RPCServer]] = [-1 :[RPCServer]()]

        sorteds.forEach({server in
            let items = sorteds.filter{$0.chainID == server.chainID}
            if items.count > 1 && !groupServers.keys.contains(server.chainID) {
                groupServers[server.chainID] = items
            } else if items.count == 1 {
                groupServers[-1]?.append(server)
            }
        })
        return groupServers
    }
}
