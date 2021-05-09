//
//  MainView.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            AdvertisingView(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "no device id")
                .tabItem {
                    Label("Connectivity", systemImage: "antenna.radiowaves.left.and.right")
                }
            
            InstanceBrowserView()
                .tabItem {
                    Label("Browser", systemImage: "network")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
