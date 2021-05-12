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
            if (instance.friendlyName != nil) {
                Text(instance.friendlyName!)
                    .bold()
            }

            Text("\(instance.address)")
        }
    }
}

struct InstanceRowView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceRow(instance: Instance(id: UUID(), address: URL(string: "192.168.0.1:6425")!, friendlyName: "bedroom"))
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
