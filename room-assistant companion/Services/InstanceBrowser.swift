//
//  InstanceBrowser.swift
//  room-assistant companion
//
//  Created by Heiko Rothe on 09.05.21.
//

import Foundation
import os

class InstanceBrowser: NSObject, ObservableObject {
    @Published var isRefreshing = false
    @Published var instances: [Instance] = []
    
    private let bonjourBrowser = NetServiceBrowser()
    private var currentServices: [NetService] = []
    
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: InstanceBrowser.self))
    
    override init() {
        super.init()

        bonjourBrowser.delegate = self
    }
    
    func findInstances() {
        isRefreshing = true
        instances = []
        
        self.bonjourBrowser.searchForServices(ofType: "_room-asst-api._tcp", inDomain: "")
    }
}

extension InstanceBrowser: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        let currentService = service
        currentServices.append(currentService)
        currentService.delegate = self
        currentService.resolve(withTimeout: 10)
        
        if !moreComing {
            isRefreshing = false
            browser.stop()
        }
    }
}

extension InstanceBrowser: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        guard let data = sender.addresses?.first else { return }
        data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
                let sockaddrPtr = pointer.bindMemory(to: sockaddr.self)
                guard let unsafePtr = sockaddrPtr.baseAddress else { return }
                guard getnameinfo(unsafePtr, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                    return
                }
            }
        let ipAddress = String(cString:hostname)
        let friendlyName = sender.hostName?.components(separatedBy: ".")[0]

        if ipAddress.isValidIpAddress {
            // IPv4 address
            var address = URLComponents()
            address.scheme = "http"
            address.host = ipAddress
            address.port = sender.port
            
            instances.append(Instance(id: UUID(), address: address.url!, friendlyName: friendlyName))
        }
    }
}

extension String {
    var isValidIpAddress: Bool {
        return self.matches(pattern: "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$")
    }
    
    var isValidUrl: Bool {
        return self.matches(pattern: "((http|https)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+")
    }
    
    private func matches(pattern: String) -> Bool {
        return self.range(of: pattern,
                          options: .regularExpression,
                          range: nil,
                          locale: nil) != nil
    }
}
