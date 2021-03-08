//
//  LocationManager.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 07.03.21.
//

import CoreLocation

class BeaconManager: NSObject {
    private let locationManager: CLLocationManager = CLLocationManager()
    private let region = CLBeaconRegion(uuid: UUID(uuidString: "D1338ACE-002D-44AF-88D1-E57C12484966")!, identifier: "io.room-assistant.instance")
    private let bluetoothManager: BluetoothManager
    
    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        super.init()
        
        locationManager.delegate = self
    }
    
    func startMonitoring() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring() {
        locationManager.stopMonitoring(for: region)
    }
    
    func isMonitoringAvailable() -> Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
            && CLLocationManager.locationServicesEnabled()
            && locationManager.authorizationStatus != .denied
    }
}

extension BeaconManager : CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted || manager.authorizationStatus == .authorizedWhenInUse {
            UserDefaults.standard.set(false, forKey: "autoToggleAdv")
            self.bluetoothManager.startAdvertising()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.bluetoothManager.addService()
        self.bluetoothManager.startAdvertising()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.bluetoothManager.stopAdvertising()
        self.bluetoothManager.removeService()
    }
}
