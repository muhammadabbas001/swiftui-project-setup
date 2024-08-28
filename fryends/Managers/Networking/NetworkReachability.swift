//
//  NetworkReachability.swift
//  Fryends (iOS)
//
//  Created by Muhammad Abbas on 5/24/22.
//

import Foundation
import Network
import SwiftUI
import Swinject

/// An enum to handle the network status
enum NetworkStatus: String {
    case connected
    case disconnected
}

/// A class that will monitor network reachability for the lifecycle of this app
//class NetworkReachabilityMonitor: ObservableObject {
//    private let monitor = NWPathMonitor()
//    private let queue = DispatchQueue(label: "Monitor")
//    private var appEventsManager = Container.default.resolver.resolve(AppEventsManager.self)
//    init() {
//        monitor.pathUpdateHandler = { [weak self] path in
//            guard let strongSelf = self else { return }
//            DispatchQueue.main.async {
//                if path.status == .satisfied {
//                    strongSelf.appEventsManager?.isConnectedToNetwork.send(true)
//                } else {
//                    strongSelf.appEventsManager?.isConnectedToNetwork.send(false)
//                }
//            }
//        }
//        monitor.start(queue: queue)
//    }
//}
