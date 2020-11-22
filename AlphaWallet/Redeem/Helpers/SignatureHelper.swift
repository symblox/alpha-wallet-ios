//
//  SignatureHelper.swift
//  Alpha-Wallet
//
//  Created by Oguzhan Gungor on 3/8/18.
//  Copyright © 2018 Alpha-Wallet. All rights reserved.
//

import Foundation
import BigInt

class SignatureHelper {
    class func signatureAsHex(for message: String, account: AlphaWallet.Address) throws -> String? {
        let keystore = try EtherKeystore(analyticsCoordinator: nil)
        let signature = keystore.signMessageData(message.data(using: String.Encoding.utf8), for: account)
        let signatureHex = try? signature.dematerialize().hex(options: .upperCase)
        guard let data = signatureHex else {
            return nil
        }
        return data
    }

    class func signatureAsDecimal(for message: String, account: AlphaWallet.Address) throws -> String? {
        guard let signatureHex = try signatureAsHex(for: message, account: account) else { return nil }
        guard let signatureDecimalString = BigInt(signatureHex, radix: 16)?.description else { return nil }
        return signatureDecimalString
    }
}
