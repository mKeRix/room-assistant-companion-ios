//
//  Instance.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import Foundation

struct Instance: Identifiable, Codable {
    var id: UUID
    var address: URL
    var friendlyName: String?
}
