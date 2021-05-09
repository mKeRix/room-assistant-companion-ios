//
//  TaskManager.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import Foundation
import BackgroundTasks
import os

class TaskManager: NSObject {
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: TaskManager.self))
    
    func registerBleAdvertisingCheck() {
        self.logger.log("Registering app refresh task")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.heikorothe.ensureBleAdvertisingState", using: nil) { (task) in
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
            }
            
            self.logger.log("Checking BLE advertising state")
            BluetoothManager.shared.ensureAdvertisingState()
            task.setTaskCompleted(success: true)
        }
    }
    
    func scheduleBleAdvertisingCheck() {
        let checkTask = BGAppRefreshTaskRequest(identifier: "com.heikorothe.ensureBleAdvertisingState")
        checkTask.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        
        do {
            try BGTaskScheduler.shared.submit(checkTask)
            self.logger.log("Succesfully submitted refresh task request")
        } catch {
            self.logger.error("Unable to submit task: \(error.localizedDescription)")
        }
    }
}
