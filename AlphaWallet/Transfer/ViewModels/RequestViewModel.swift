// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit

struct RequestViewModel {
	private let account: Wallet
    private let server: RPCServer

    private let generatingImageCodeType = Constants.MyAddressStringRPCServerType
    private let copiedAddressType = Constants.MyAddressStringRPCServerType
    
	init(account: Wallet, server: RPCServer) {
		self.account = account
		self.server = server
	}
    
	var myAddressText: String {
        if Constants.MyAddressStringRPCServerType == .velas {
            return vlxAddressString
        }
		return account.address.eip55String
	}

    var generatingAddressString : String {
        if generatingImageCodeType == .velas {
            return myAddressText
        }
        return account.address.eip55String
    }
    
    var copiedAddressString : String {
        if generatingImageCodeType == .velas {
            return myAddressText
        }
        return account.address.eip55String
    }
    
	var myAddress: AlphaWallet.Address {
		return account.address
	}

	var shareMyAddressText: String {
		return R.string.localizable.requestMyAddressIsLabelTitle(server.name, myAddressText)
	}

	var copyWalletText: String {
		return R.string.localizable.requestCopyWalletButtonTitle()
	}

	var addressCopiedText: String {
		return R.string.localizable.requestAddressCopiedTitle()
	}

	var backgroundColor: UIColor {
		return Colors.appBackground
	}

	var addressLabelColor: UIColor {
		return .black
	}

	var copyButtonsFont: UIFont {
		return Fonts.semibold(size: 17)!
	}

	var labelColor: UIColor? {
		return R.color.mine()
	}

	var addressFont: UIFont {
		return Fonts.semibold(size: 17)!
	}

	var addressBackgroundColor: UIColor {
		return UIColor(red: 237, green: 237, blue: 237)
	}

	var instructionFont: UIFont {
		return Fonts.regular(size: 17)!
	}

	var instructionText: String {
		return R.string.localizable.aWalletAddressScanInstructions()
	}
    
    var vlxAddressString: String {
        let string = account.address.eip55String
        if VelasConvertUtil.isVlxAddress(string) {
            return string
        } else {
            return VelasConvertUtil.ethToVlx(hexAddress: string)
        }
    }
}
