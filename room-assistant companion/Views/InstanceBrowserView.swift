//
//  InstanceBrowserView.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import SwiftUI

struct InstanceBrowserView: View {
    @StateObject var browser = InstanceBrowser()
    
    var body: some View {
        NavigationView {
            List(browser.instances) { instance in
                NavigationLink(destination: InstanceDetailView(instance: instance)) {
                    InstanceRow(instance: instance)
                }
            }
            .onAppear {
                browser.findInstances()
            }
            .navigationTitle("Instances")
        }
    }
}

struct InstanceBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceBrowserView()
    }
}
