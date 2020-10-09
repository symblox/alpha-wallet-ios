//
//  VelasConvertUtil.swift
//  AlphaWallet
//
//  Created by Nam Phan on 10/9/20.
//

import Foundation
import CryptoKit

struct VelasConvertUtil {
    private static let ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
   // private var ALPHABET_MAP: [Character: Int] = [:]
    private static let BASE = 58
    private static let BITS_PER_DIGIT: Double = log(Double(58)) / log(2)

    public static func containsHexPrefix(_ input: String) -> Bool {
        return (input.lengthOfBytes(using: .utf8) > 1 && input.hasPrefix("0x"))
    }
    
    public static func cleanHexPrefix(input: String) -> String {
        if containsHexPrefix(input) {
            return input.substring(from: 2)
        }
        return input
    }
    
    public static func isVlxAddress(_ input: String) -> Bool {
        if input.isEmpty {
            return false
        }
        return input.hasPrefix("V") && input.lengthOfBytes(using: .utf8) == 34
    }
    
    private static func maxEncodedLen(n: Int) -> Int {
        return Int(ceil(Double(n) / BITS_PER_DIGIT))
    }
    
    private static func sha256(string: String) -> String {
        if #available(iOS 13.0, *) {
            let data = string.data(using: .utf8) ?? Data()
            let hashed = SHA256.hash(data: data)
            let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            return hashString
        } else {
            return ""
        }
    }
    
    public static func ethToVlx(hexAddress: String) -> String {
        let cleanAddress = VelasConvertUtil.cleanHexPrefix(input: hexAddress).lowercased()
        if cleanAddress.lengthOfBytes(using: .utf8) != 40 {
            return hexAddress
        }
        let checksum = sha256(string: sha256(string: cleanAddress)).substring(to: 8)
        let longAddress = cleanAddress + checksum
        let buffer = hexStringToByteArray(longAddress)
        if buffer.isEmpty {
            return hexAddress
        }
        var digits = [Int]()
        digits.append(0)
        for i in 0 ..< buffer.count {
            for j in 0 ..< digits.count {
                digits[j] = digits[j] << 8
            }
            digits[0] = digits[0] + Int(buffer[i])
            var carry: Int = 0
            for j in 0 ..< digits.count {
                digits[j] = digits[j] + carry
                carry = (digits[j] / BASE) | 0
                digits[j] = digits[j] % BASE
            }
            while carry > 0 {
                digits.append(carry % BASE)
                carry = (carry / BASE) | 0
            }
        }
        let zeros = Int(maxEncodedLen(n: buffer.count) - digits.count)
        if zeros > 0 {
            for _ in 0 ..< zeros {
                digits.append(0)
            }
        }
        let vlxAddress = digits.reversed().compactMap {String(Character(UnicodeScalar(ALPHABET.bytes[$0])))}.joined()
        return "V" + vlxAddress
    }
    
    public static func vlxToEth(vlxAddress: String) -> String {
        if !isVlxAddress(vlxAddress) {
            return vlxAddress
        }
        let cleanAddress = vlxAddress.substring(from: 1)
        var ALPHABET_MAP: [String: Int] = [:]
        for i in 0 ..< ALPHABET.lengthOfBytes(using: .utf8) {
            ALPHABET_MAP[String(Character(UnicodeScalar(ALPHABET.bytes[i])))] = i
        }
        
        var digits = [Int]()
        digits.append(0)
        for i in 0 ..< cleanAddress.lengthOfBytes(using: .utf8) {
            let c = String(Character(UnicodeScalar(cleanAddress.bytes[i])))
            if ALPHABET_MAP[c] == nil {
                return vlxAddress
            }
            for j in 0 ..< digits.count {
                digits[j] = digits[j] * BASE
            }
            digits[0] = digits[0] + (ALPHABET_MAP[c] ?? 0)
            var carry: Int = 0
            for j in 0 ..< digits.count {
                digits[j] = digits[j] + carry
                carry = (digits[j] >> 8)
                digits[j] = digits[j] & 0xff
            }
            while carry > 0 {
                digits.append(carry & 0xff)
                carry = carry >> 8
            }
        }
        let zeros = 24 - digits.count
        if zeros > 0 {
            for _ in 0 ..< zeros {
                digits.append(0)
            }
        }
        let longAddress = digits.reversed().compactMap {String(format: "%02x", $0)}.joined()
        if longAddress.lengthOfBytes(using: .utf8) != 48 {
            return vlxAddress
        }
        let ethAddress = longAddress.substring(to: 40)
        let addressChecksum = longAddress.substring(from: 40)
        let checksum = sha256(string: sha256(string: ethAddress)).substring(to: 8)
        if checksum != addressChecksum {
            return vlxAddress
        }
        return "0x" + ethAddress
    }
    
    public static func hexStringToByteArray(_ input: String) -> [UInt] {
        let cleanInput = cleanHexPrefix(input: input)
        if cleanInput.lengthOfBytes(using: .utf8) == 0 {
            return [UInt]()
        }
        let len = cleanInput.lengthOfBytes(using: .utf8)
        var data: [UInt]
        var startIdx: Int = 0
        if len % 2 != 0 {
            data = [UInt](repeating: 0, count: (len / 2) + 1)
            data[0] = UInt(cleanInput.substring(to: 2), radix: 16) ?? 0
            startIdx = 1
        } else {
            startIdx = 0
            data = [UInt](repeating: 0, count: (len / 2))
        }
        for i in stride(from: startIdx, to: len, by: 2) {
            let subHex = cleanInput.substring(with: Range(uncheckedBounds: (i, i + 2)))
            data[i / 2] = UInt(subHex, radix: 16) ?? 0
        }
        return data
    }
}
