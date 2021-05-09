//
//  InstanceRowView.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import SwiftUI

struct InstanceRow: View {
    var instance: Instance
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(instance.id.components(separatedBy: ".")[0])
                .bold()
            Text("\(instance.ipAddress):\(String(instance.port))")
        }
    }
}

struct InstanceRowView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceRow(instance: Instance(id: "bedroom.local.", ipAddress: "192.168.0.1", port: 6425))
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
