//
//  InstanceClient.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import Foundation
import Starscream
import os

class InstanceClient: NSObject, ObservableObject {
    @Published var isRefreshing = false
    @Published var entities: [Entity] = []
    
    private var socket: WebSocket?
    
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: InstanceClient.self))
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func populateEntities(instance: Instance) {
        retrieveEntities(instance: instance) {
            self.connectSocket(instance: instance)
        }
    }
    
    func cleanUp() {
        socket?.disconnect()
    }
    
    private func retrieveEntities(instance: Instance, finished:@escaping () -> ()) {
        guard let url = URL(string: "http://\(instance.ipAddress):\(String(instance.port))/entities") else {
            self.logger.error("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        
        isRefreshing = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode([Entity].self, from: data) {
                    DispatchQueue.main.async {
                        self.isRefreshing = false
                        self.entities = response
                        finished()
                    }
                }
            }
        }.resume()
    }
    
    private func connectSocket(instance: Instance) {
        guard let url = URL(string: "http://\(instance.ipAddress):\(String(instance.port))") else {
            self.logger.error("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        socket = WebSocket(request: request)
        socket!.delegate = self
        socket!.connect()
    }
    
    private func subscribeEntityUpdates() {
        let request = SocketRequest(event: "subscribeEvents", data: SubscriptionRequestData(type: "entityUpdates"))
        
        if let message = try? encoder.encode(request) {
            socket?.write(string: String(data: message, encoding: .utf8)!)
        }
    }
}

extension InstanceClient: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_) :
            self.subscribeEntityUpdates()
        case .text(let value):
            if let update = try? decoder.decode(EntityUpdateMessage.self, from: value.data(using: .utf8)!) {
                if let index = self.entities.firstIndex(where: {$0.id == update.entity.id}) {
                    self.entities[index] = update.entity
                } else {
                    self.entities.append(update.entity)
                }
            }
        default:
            break
        }
    }
}

struct SocketRequest: Codable {
    let event: String
    let data: SubscriptionRequestData
}

struct SubscriptionRequestData: Codable {
    let type: String
}

struct EntityUpdateMessage: Decodable {
    let entity: Entity
}
