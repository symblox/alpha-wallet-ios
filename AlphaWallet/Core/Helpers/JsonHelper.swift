//
//  JsonHelper.swift
//  AlphaWallet

import Foundation


func readStringFile(_ name: String, bundle: Bundle?) -> String? {
    let selfBundle = bundle ?? Bundle.main
    if let path = selfBundle.path(forResource: name, ofType: "json") {
        var text = ""
        do {
            text = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            return text
        }
        return text
    }
    return nil
}

func objectDataFromFile<T: Codable>(_ name:String, type: T.Type) throws -> T {
    if let filePath = Bundle.main.url(forResource: name, withExtension: ".json") {
        let decoder = JSONDecoder()

        guard let data = try? Data(contentsOf: filePath) else {
            throw ParserError.FileEmpty
        }
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw ParserError.InvalidFormat
        }
    }
    throw ParserError.FileNotFound
}

enum ParserError: Error {
    case InvalidFormat, Unknow, FileEmpty, FileNotFound
}
