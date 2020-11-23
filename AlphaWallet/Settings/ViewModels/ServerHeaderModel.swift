//
//  ServerHeaderModel.swift
//  AlphaWallet
//
//  Created by tutrang on 11/19/20.
//

import Foundation

struct ServerHeaderModel {

    public init() {}
    
    public init(name: String) {
        self._name = name
    }
    
    var _name: String?
    var title: String {
        return _name ?? "Header Title"
    }
    
}
