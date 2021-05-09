//
//  Entity.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import Foundation

enum EntityState {
    case boolean (Bool)
    case numeric (Double)
    case string (String)
    
    func getStringRepresentation() -> String {
        switch self {
        case .boolean(let v):
            return String(v)
        case .numeric(let v):
            return String(v)
        case .string(let v):
            return v
        }
    }
}

struct Entity: Identifiable {
    let id: String
    let name: String
    var state: EntityState?
}

extension Entity: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case state
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        
        if let v = try? values.decode(Bool.self, forKey: .state) {
            state = .boolean(v)
        } else if let v = try? values.decode(Double.self, forKey: .state) {
            state = .numeric(v)
        } else if let v = try? values.decode(String.self, forKey: .state) {
            state = .string(v)
        }
    }
}
