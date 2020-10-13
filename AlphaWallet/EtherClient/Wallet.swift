// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum WalletType: Equatable {
    case real(EthereumAccount)
    case watch(AlphaWallet.Address)
}

struct Wallet: Equatable {
    let type: WalletType

    var address: AlphaWallet.Address {
        switch type {
        case .real(let account):
            return account.address
        case .watch(let address):
            return address
        }
    }
    
    var allowBackup: Bool {
        switch type {
        case .real:
            return true
        case .watch:
            return false
        }
    }
    
    var vlxAddress: String {
        if (!address.eip55String.isEmpty && address.eip55String.hasPrefix("0x")) {
            return VelasConvertUtil.ethToVlx(hexAddress: address.eip55String)
        }
        return address.eip55String;
    }
}
