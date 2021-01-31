//
//  BluetoothManager.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 23.10.20.
//

import UIKit
import CoreBluetooth

class BluetoothManager: NSObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager?
    private var raCharacteristicId: CBUUID = CBUUID(nsuuid: UUID(uuidString: "21c46f33-e813-4407-8601-2ad281030052")!)
    private var raServiceId: CBUUID = CBUUID(nsuuid: UUID(uuidString: "5403c8a7-5c96-47e9-9ab8-59e373d875a7")!)
    private var raCharacteristic: CBMutableCharacteristic!
    
    override init() {
        raCharacteristic = CBMutableCharacteristic(type: raCharacteristicId, properties: [.read], value: UIDevice.current.identifierForVendor?.uuidString.data(using: .utf8), permissions: [.readable])
        super.init()
        
        peripheralManager = CBPeripheralManager.init(delegate: self, queue: nil, options: [CBPeripheralManagerOptionRestoreIdentifierKey: "peripheralManagerIdentifier"])
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            addService()
            startAdvertising()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        let restoredServices: [CBMutableService] = dict[CBPeripheralManagerRestoredStateServicesKey] as? [CBMutableService] ?? []
        
        let raServiceInitialized = restoredServices.contains { element in
            return element.uuid == raServiceId
        }
        
        if !raServiceInitialized {
            addService()
        }
        
        startAdvertising()
    }
    
    func addService() -> Void {
        peripheralManager!.removeAllServices()
        
        let raService = CBMutableService(type: raServiceId, primary: true)
        raService.characteristics = [raCharacteristic]
        
        peripheralManager!.add(raService)
    }
    
    func startAdvertising() -> Void {
        peripheralManager!.startAdvertising([CBAdvertisementDataLocalNameKey: "room-assistant companion", CBAdvertisementDataServiceUUIDsKey: [raServiceId]])
    }
}
