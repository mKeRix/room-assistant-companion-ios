//
//  ContentView.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 23.10.20.
//

import SwiftUI

struct ContentView: View {
    private let bluetoothManager: BluetoothManager = BluetoothManager.init()
    private let locationManager: BeaconManager
    private let deviceId: String
    
    @State private var justCopied = false
    @AppStorage("autoToggleAdv") private var autoToggleAdv = false
    
    init(deviceId: String) {
        self.locationManager = BeaconManager(bluetoothManager: self.bluetoothManager)
        self.deviceId = deviceId
    }
    
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200, alignment:  .center)
            Text("room-assistant companion")
                .font(.title)
                .padding()
            Text("You should enter the ID below into your bluetoothLowEnergy integration allowlist. Once you have granted Bluetooth permissions to this app room-assistant will be able to see your iPhone!")
                .padding()
            Text("Device ID (tap to copy):")
            
            if (justCopied) {
                Text("Copied to clipboard!")
                    .italic()
                    .padding()
            } else {
                Text(deviceId)
                    .padding()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .onTapGesture {
                        UIPasteboard.general.string = deviceId
                        
                        justCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            justCopied = false
                        }
                    }
            }
            
            Toggle(isOn: $autoToggleAdv, label: {
                Text("Auto-Toggle Advertising")
            }).padding()
            .disabled(!self.locationManager.isMonitoringAvailable())
            .onChange(of: autoToggleAdv, perform: { value in
                if value {
                    self.locationManager.startMonitoring()
                } else {
                    self.locationManager.stopMonitoring()
                }
            })

        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(deviceId: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
    }
}
