//
//  InstanceDetail.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import SwiftUI

struct InstanceDetailView: View {
    @StateObject var client = InstanceClient()
    
    var instance: Instance
    
    var body: some View {
        VStack {
            if (client.isRefreshing) {
                ProgressView()
            }
            
            List(Array(client.entities)) { entity in
                EntityRow(entity: entity)
            }
            .onAppear() {
                client.populateEntities(instance: instance)
            }
            .onDisappear() {
                client.cleanUp()
            }
            .navigationTitle(instance.id.components(separatedBy: ".")[0])
        }
        
    }
}

struct InstanceDetail_Previews: PreviewProvider {
    static var previews: some View {
        InstanceDetailView(instance: Instance(id: "kitchen.local.", ipAddress: "192.168.0.1", port: 6425))
    }
}
