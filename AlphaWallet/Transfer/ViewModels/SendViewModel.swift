// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit
import BigInt

struct SendViewModel {
    private let session: WalletSession
    private let storage: TokensDataStore

    let transferType: TransferType

    init(transferType: TransferType, session: WalletSession, storage: TokensDataStore) {
        self.transferType = transferType
        self.session = session
        self.storage = storage
    }

    var destinationAddress: AlphaWallet.Address {
        return transferType.contract
    }

    var backgroundColor: UIColor {
        return Colors.appBackground
    }

    var token: TokenObject? {
        switch transferType {
        case .nativeCryptocurrency:
            return nil
        case .ERC20Token(let token, _, _):
            return token
        case .ERC875Token(let token):
            return token
        case .ERC875TokenOrder(let token):
            return token
        case .ERC721Token(let token):
            return token
        case .ERC721ForTicketToken(let token):
            return token
        case .dapp, .tokenScript:
            return nil
        }
    }

    var textFieldsLabelTextColor: UIColor {
        return Colors.appGrayLabel
    }
    var textFieldsLabelFont: UIFont {
        return Fonts.regular(size: 10)!
    }

    var recipientLabelFont: UIFont {
        return Fonts.regular(size: 13)!
    }

    var recepientLabelTextColor: UIColor {
        return R.color.dove()!
    }

    var recipientsAddress: String {
        return R.string.localizable.sendRecipientsAddress()
    }

    var amountTextFieldPair: AmountTextField.Pair {
        return AmountTextField.Pair(left: .cryptoCurrency(transferType.tokenObject), right: .usd)
    }

    var selectCurrencyButtonHidden: Bool {
        switch transferType {
        case .nativeCryptocurrency:
            guard let currentTokenInfo = storage.tickers?[destinationAddress], currentTokenInfo.price_usd > 0 else {
                return true
            }
            return false
        case .ERC20Token, .ERC875Token, .ERC875TokenOrder, .ERC721Token, .ERC721ForTicketToken, .dapp, .tokenScript:
            return true
        }
    }

    var currencyButtonHidden: Bool {
        switch transferType {
        case .nativeCryptocurrency, .ERC20Token:
            return false
        case .ERC875Token, .ERC875TokenOrder, .ERC721Token, .ERC721ForTicketToken, .dapp, .tokenScript:
            return true
        }
    }

    var availableLabelText: String? {
        switch transferType {
        case .nativeCryptocurrency:
            if let balance = session.balance {
                let value = EtherNumberFormatter.plain.string(from: balance.value)
                return R.string.localizable.sendAvailable("\(value) \(transferType.symbol)")
            }
        case .ERC20Token(let token, _, _):
            let value = EtherNumberFormatter.plain.string(from: token.valueBigInt, decimals: token.decimals)
            return R.string.localizable.sendAvailable("\(value) \(transferType.symbol)")
        case .dapp, .ERC721ForTicketToken, .ERC721Token, .ERC875Token, .ERC875TokenOrder, .tokenScript:
            break
        }

        return nil
    }

    var availableTextHidden: Bool {
        switch transferType {
        case .nativeCryptocurrency:
            return session.balance == nil
        case .ERC20Token(let token, _, _):
            let tokenBalance = storage.token(forContract: token.contractAddress)?.valueBigInt
            return tokenBalance == nil
        case .dapp, .ERC721ForTicketToken, .ERC721Token, .ERC875Token, .ERC875TokenOrder, .tokenScript:
            break
        }
        return true
    }

    func validatedAmount(value amountString: String, checkIfGreaterThanZero: Bool = true) -> BigInt? {
        let parsedValue: BigInt? = {
            switch transferType {
            case .nativeCryptocurrency, .dapp, .tokenScript:
                return EtherNumberFormatter.full.number(from: amountString, units: .ether)
            case .ERC20Token(let token, _, _):
                return EtherNumberFormatter.full.number(from: amountString, decimals: token.decimals)
            case .ERC875Token(let token):
                return EtherNumberFormatter.full.number(from: amountString, decimals: token.decimals)
            case .ERC875TokenOrder(let token):
                return EtherNumberFormatter.full.number(from: amountString, decimals: token.decimals)
            case .ERC721Token(let token):
                return EtherNumberFormatter.full.number(from: amountString, decimals: token.decimals)
            case .ERC721ForTicketToken(let token):
                return EtherNumberFormatter.full.number(from: amountString, decimals: token.decimals)
            }
        }()

        guard let value = parsedValue, checkIfGreaterThanZero ? value > 0 : true else {
            return nil
        }

        switch transferType {
        case .nativeCryptocurrency:
            if let balance = session.balance, balance.value < value {
                return nil
            }
        case .ERC20Token(let token, _, _):
            if let tokenBalance = storage.token(forContract: token.contractAddress)?.valueBigInt, tokenBalance < value {
                return nil
            }
        case .dapp, .ERC721ForTicketToken, .ERC721Token, .ERC875Token, .ERC875TokenOrder, .tokenScript:
            break
        }

        return value

    }
}
