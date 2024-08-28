//
//  SwinjectContainer+Extensions.swift
//  Fryends (iOS)
//
//  Created by Muhammad Abbas on 5/24/22.
//

import Foundation
import Swinject

extension Container {
    enum `default` {
        static let container: Container = {
            Container()
        }()
        static let resolver: Resolver = {
            container.synchronize()
        }()
    }
}
