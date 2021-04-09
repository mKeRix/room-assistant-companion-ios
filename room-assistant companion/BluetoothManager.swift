//
//  BluetoothManager.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 23.10.20.
//

import UIKit
import CoreBluetooth
import CoreLocation
import os

class BluetoothManager: NSObject {
    private var peripheralManager: CBPeripheralManager?
    private let raCharacteristicId: CBUUID = CBUUID(nsuuid: UUID(uuidString: "21c46f33-e813-4407-8601-2ad281030052")!)
    private let raServiceId: CBUUID = CBUUID(nsuuid: UUID(uuidString: "5403c8a7-5c96-47e9-9ab8-59e373d875a7")!)
    private let raCharacteristic: CBMutableCharacteristic
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private let region = CLBeaconRegion(uuid: UUID(uuidString: "D1338ACE-002D-44AF-88D1-E57C12484966")!, identifier: "io.room-assistant.instance")
    
    private var beaconNearby: Bool = false
    
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: BluetoothManager.self))
    
    override init() {
        raCharacteristic = CBMutableCharacteristic(type: raCharacteristicId, properties: [.read], value: UIDevice.current.identifierForVendor?.uuidString.data(using: .utf8), permissions: [.readable])
        super.init()
        
        peripheralManager = CBPeripheralManager.init(delegate: self, queue: nil, options: [CBPeripheralManagerOptionRestoreIdentifierKey: "peripheralManagerIdentifier"])
        locationManager.delegate = self
    }
    
    func shouldBeAdvertising() -> Bool {
        return !UserDefaults.standard.bool(forKey: "autoToggleAdv") || beaconNearby
    }
    
    func startAdvertising() -> Void {
        peripheralManager!.removeAllServices()
        
        let raService = CBMutableService(type: raServiceId, primary: true)
        raService.characteristics = [raCharacteristic]
        peripheralManager!.add(raService)
        
        if peripheralManager!.state == .poweredOn {
            peripheralManager!.startAdvertising([CBAdvertisementDataLocalNameKey: "room-assistant companion", CBAdvertisementDataServiceUUIDsKey: [raServiceId]])
        }
    }
    
    func stopAdvertising() {
        peripheralManager!.stopAdvertising()
        peripheralManager!.removeAllServices()
    }
    
    func enableAdvAutoToggling() {
        self.logger.log("Stopping advertising due to event: enabled advertisement auto toggling")
        stopAdvertising()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoring(for: region)
        searchBeacon()
    }
    
    func disableAdvAutoToggling() {
        locationManager.stopMonitoring(for: region)
        
        self.logger.log("Starting advertising due to event: disabled advertisement auto toggling")
        startAdvertising()
    }
    
    func isMonitoringAvailable() -> Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
            && CLLocationManager.locationServicesEnabled()
            && locationManager.authorizationStatus != .denied
    }
    
    private func searchBeacon() {
        if CLLocationManager.isRangingAvailable() {
            locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint.init(uuid: region.uuid))
        }
    }
}

extension BluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if (peripheral.state == .poweredOn && self.shouldBeAdvertising()) {
            self.logger.log("Starting advertising due to event: went into poweredOn state")
            startAdvertising()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        if (self.shouldBeAdvertising()) {
            self.logger.log("Starting advertising due to event: restored peripheral manager")
            startAdvertising()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            self.logger.error("Error when adding service \(service.uuid): \(error.debugDescription)")
        } else {
            self.logger.log("Succesfully added service \(service.uuid)")
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            self.logger.error("Error when starting advertising: \(error.debugDescription)")
        } else {
            self.logger.log("Succesfully started advertising")
        }
    }
}

extension BluetoothManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted || manager.authorizationStatus == .authorizedWhenInUse {
            UserDefaults.standard.set(false, forKey: "autoToggleAdv")
            self.logger.log("Starting advertising due to event: authorizationStatus went into \(String(describing: manager.authorizationStatus))")
            startAdvertising()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.logger.log("Starting advertising due to event: entered beacon region")

        startAdvertising()
        beaconNearby = true
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.logger.log("Stopping advertising due to event: exited beacon region")
        
        stopAdvertising()
        beaconNearby = false
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        self.logger.log("Starting advertising due to event: ranged beacon region")
        
        startAdvertising()
        
        locationManager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint.init(uuid: region.uuid))
    }
}
