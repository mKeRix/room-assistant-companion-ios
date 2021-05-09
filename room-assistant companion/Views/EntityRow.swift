//
//  EntityRow.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import SwiftUI

struct EntityRow: View {
    var entity: Entity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entity.name)
                    .bold()
                Text(entity.id)
                    .font(.caption)
            }
            
            Spacer()
            Text(entity.state?.getStringRepresentation() ?? "")
        }
    }
}

struct EntityRow_Previews: PreviewProvider {
    static var previews: some View {
        EntityRow(entity: Entity(id: "ble-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx-tracker", name: "iPhone Tracker", state: .string("home")))
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
