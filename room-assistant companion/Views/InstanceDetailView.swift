//
//  InstanceDetail.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import SwiftUI

struct InstanceDetailView: View {
    @State var entities: [Entity] = []
    @State private var isRefreshing = false
    
    var instance: Instance
    
    var body: some View {
        VStack {
            if (isRefreshing) {
                ProgressView()
            }
            
            List(entities) { entity in
                EntityRow(entity: entity)
            }
            .onAppear() {
                isRefreshing = true
                InstanceClient(instance: instance).retrieveEntities { entities in
                    self.entities = entities
                    isRefreshing = false
                }
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
