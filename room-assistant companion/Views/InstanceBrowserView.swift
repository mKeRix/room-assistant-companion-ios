//
//  InstanceBrowserView.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import SwiftUI

struct InstanceBrowserView: View {
    @StateObject private var browser = InstanceBrowser()
    @State private var manualAddress = ""
    @State private var isInvalidAddress = false
    
    @AppStorage("savedInstances") private var savedInstances: [Instance] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(browser.instances) { instance in
                    NavigationLink(destination: InstanceDetailView(instance: instance)) {
                        InstanceRow(instance: instance)
                    }
                }
                
                ForEach(savedInstances) { instance in
                    NavigationLink(destination: InstanceDetailView(instance: instance)) {
                        InstanceRow(instance: instance)
                    }
                }.onDelete { savedInstances.remove(atOffsets: $0)
                }
                .onMove { savedInstances.move(fromOffsets: $0, toOffset: $1)
                }
                
                TextField("Instance address", text: $manualAddress, onCommit: addManualInstance)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .alert(isPresented: $isInvalidAddress) {
                        Alert(title: Text("Invalid address entered"))
                    }
            }
            .onAppear(perform: refresh)
            .navigationTitle("Instances")
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: refresh) {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    EditButton()
                }
            })
        }
    }
    
    func addManualInstance() {
        let formattedAddress = manualAddress.starts(with: "http") ? manualAddress : "http://" + manualAddress
        guard let url = URL(string: formattedAddress) else {
            isInvalidAddress = true
            return
        }
        
        let instance = Instance(id: UUID(), address: url)
        
        savedInstances.append(instance)
        manualAddress = ""
    }
    
    func refresh() {
        browser.findInstances()
    }
}

struct InstanceBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceBrowserView()
    }
}
