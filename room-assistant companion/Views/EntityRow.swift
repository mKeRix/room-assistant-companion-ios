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
        VStack(alignment: .leading) {
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
            
            if (entity.distances != nil) {
                Spacer()
                    .frame(height: 10)
                
                ForEach(entity.distances!.sorted(by: {$0.key < $1.key}), id: \.key) { key, value in
                    Text("\(key): \(String(format: "%.1f", value.distance)) m")
                        .font(.caption)
                        .foregroundColor(value.outOfRange ? .red : .black)
                }
            }
        }
    }
}

struct EntityRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EntityRow(entity: Entity(id: "ble-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx-tracker", name: "iPhone Tracker", state: .string("home")))
                .previewLayout(.fixed(width: 300, height: 70))
            
            EntityRow(entity: Entity(id: "ble-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx-tracker", name: "iPhone Tracker", state: .string("home"), distances: ["kitchen": DistanceMeasurement(distance: 1.2, outOfRange: false), "bedroom": DistanceMeasurement(distance: 5.1, outOfRange: true)]))
                .previewLayout(.fixed(width: 300, height: 140))
        }
    }
}
