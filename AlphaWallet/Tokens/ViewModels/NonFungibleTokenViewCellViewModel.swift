// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit
import BigInt

struct NonFungibleTokenViewCellViewModel {
    private let token: TokenObject
    private let server: RPCServer
    private let assetDefinitionStore: AssetDefinitionStore
    private let isVisible: Bool

    init(token: TokenObject, server: RPCServer, assetDefinitionStore: AssetDefinitionStore, isVisible: Bool = true) {
        self.token = token
        self.server = server
        self.assetDefinitionStore = assetDefinitionStore
        self.isVisible = isVisible
    }

    var title: String {
        return token.titleInPluralForm(withAssetDefinitionStore: assetDefinitionStore)
    }

    var amount: String {
        let actualBalance = token.nonZeroBalance
        return actualBalance.count.toString()
    }

    var blockChainNameFont: UIFont {
        return Screen.TokenCard.Font.blockChainName
    }

    var blockChainNameColor: UIColor {
        return Screen.TokenCard.Color.blockChainName
    }

    var blockChainNameBackgroundColor: UIColor {
        return server.blockChainNameColor
    }

    var blockChainTag: String {
        return "  \(server.name)     "
    }

    var blockChainNameTextAlignment: NSTextAlignment {
        return .center
    }

    var blockChainNameCornerRadius: CGFloat {
        return Screen.TokenCard.Metric.blockChainTagCornerRadius
    }

    var blockChainName: String {
        return server.blockChainName
    }

    var backgroundColor: UIColor {
        return Screen.TokenCard.Color.background
    }

    var contentsBackgroundColor: UIColor {
        return Screen.TokenCard.Color.background
    }

    var contentsCornerRadius: CGFloat {
        return Metrics.CornerRadius.box
    }

    var titleColor: UIColor {
        return Screen.TokenCard.Color.title
    }

    var subtitleColor: UIColor {
        return Screen.TokenCard.Color.subtitle
    }

    var titleFont: UIFont {
        return Screen.TokenCard.Font.title
    }

    var subtitleFont: UIFont {
        return Screen.TokenCard.Font.subtitle
    }

    var alpha: CGFloat {
        return isVisible ? 1.0 : 0.4
    }

    var iconImage: Subscribable<TokenImage> {
        token.icon
    }

    var blockChainTagViewModel: BlockchainTagLabelViewModel {
        return .init(server: server)
    }

}
