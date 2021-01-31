//
//  room_assistant_companionApp.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 23.10.20.
//

import SwiftUI
import UIKit

@main
struct room_assistant_companionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "no device id")
        }
    }
}
