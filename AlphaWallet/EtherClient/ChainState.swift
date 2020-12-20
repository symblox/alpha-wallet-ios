// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import APIKit
import PromiseKit

class ChainState {

    struct Keys {
        static let latestBlock = "chainID"
    }

    private let server: RPCServer

    private var latestBlockKey: String {
        return "\(server.chainID)-" + Keys.latestBlock
    }

    var latestBlock: Int {
        get {
            return defaults.integer(forKey: latestBlockKey)
        }
        set {
            defaults.set(newValue, forKey: latestBlockKey)
        }
    }
    let defaults: UserDefaults

    var updateLatestBlock: Timer?

    init(config: Config, server: RPCServer) {
        self.server = server
        self.defaults = config.defaults
        if config.isAutoFetchingDisabled {
            //No-op
        } else {
            self.updateLatestBlock = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
        }
    }

    func start() {
        fetch()
    }

    func stop() {
        updateLatestBlock?.invalidate()
        updateLatestBlock = nil
    }

    @objc func fetch() {
        let request = EtherServiceRequest(server: server, batch: BatchFactory().create(BlockNumberRequest()))
        firstly {
            Session.send(request)
        }.done {
            self.latestBlock = $0
        }.cauterize()
    }

    func confirmations(fromBlock: Int) -> Int? {
        guard fromBlock > 0 else { return nil }
        let block = latestBlock - fromBlock
        guard latestBlock != 0, block > 0 else { return nil }
        return max(0, block)
    }

}
