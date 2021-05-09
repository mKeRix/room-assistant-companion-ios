//
//  InstanceClient.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import Foundation
import os

class InstanceClient: NSObject {
    let instance: Instance
    
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: InstanceClient.self))
    
    init(instance: Instance) {
        self.instance = instance
        super.init()
    }
    
    func retrieveEntities(finished:@escaping ([Entity]) -> ()) {
        guard let url = URL(string: "http://\(instance.ipAddress):\(String(instance.port))/entities") else {
            self.logger.error("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode([Entity].self, from: data) {
                    DispatchQueue.main.async {
                        finished(response)
                    }
                }
            }
        }.resume()
    }
}
