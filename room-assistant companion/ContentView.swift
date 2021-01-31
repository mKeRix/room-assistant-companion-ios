//
//  ContentView.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 23.10.20.
//

import SwiftUI

struct ContentView: View {
    private var bluetoothManager: BluetoothManager = BluetoothManager.init()
    private var deviceId: String
    
    @State var justCopied = false
    
    init(deviceId: String) {
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
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(deviceId: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
    }
}
