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
    @Environment(\.scenePhase) private var scenePhase
    
    private let taskManager = TaskManager.init()
    
    init() {
        taskManager.registerBleAdvertisingCheck()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            if (newScenePhase == .background) {
                taskManager.scheduleBleAdvertisingCheck()
            }
        }
    }
}
