//
//  LocalERCToken.swift
//  AlphaWallet
//
import Foundation


struct LocalERCToken: Codable {
    
    var contract: AlphaWallet.Address?
    var server: RPCServer?
    let name: String
    let symbol: String
    let decimal: Int
    let type: TokenType = .nativeCryptocurrency
    var visible = false
    
    enum Key: CodingKey {
        case contract
        case server
        case name
        case symbol
        case decimal
        case visible
    }
    
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.decimal = try container.decode(Int.self, forKey: .decimal)
        self.visible = try container.decode(Bool.self, forKey: .visible)
        if let address = try? container.decode(String.self, forKey: .contract) {
            contract = AlphaWallet.Address(string: address)
        }
        if let inputServer = try? container.decode(Int.self, forKey: .server) {
            server = RPCServer(chainID: inputServer)
        }
    }

     func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: Key.self)
     }
}
