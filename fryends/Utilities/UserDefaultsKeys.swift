//
//  UserDefaultsKeys.swift
//  Fryends (IOS)
//
//  Created by Muhammad Abbas 20/02/2023.
//

import Foundation
import UIKit
import SwiftUI

struct UserDefaultsKeys{
    static let jwt = "fcm-token"
    
    static func clearUserDefaults(){
        UserDefaults.standard.removeObject(forKey: jwt)
    }
}

extension UserDefaults {
    var jwt: String? {
        get {
            UserDefaults.standard.value(forKey: UserDefaultsKeys.jwt) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.jwt)
        }
    }
}
