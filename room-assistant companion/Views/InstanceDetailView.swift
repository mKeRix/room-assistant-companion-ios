//
//  InstanceDetail.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import SwiftUI

struct InstanceDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
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
            .alert(isPresented: $client.experiencedError) {
                Alert(title: Text("Connection Error"), message: Text("Check if the specified address is correct and make sure that your phone has access to it."), dismissButton: .cancel { presentationMode.wrappedValue.dismiss() })
            }
            .navigationTitle(instance.friendlyName ?? "Entities")
        }
        
    }
}

struct InstanceDetail_Previews: PreviewProvider {
    static var previews: some View {
        InstanceDetailView(instance: Instance(id: UUID(), address: URL(string: "192.168.0.1:6425")!))
    }
}
