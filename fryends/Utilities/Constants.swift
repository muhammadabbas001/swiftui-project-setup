//
//  Constants.swift
//  Fryends (IOS)
//
//  Created by Muhammad Abbas on 9/8/23.
//

import Foundation
import UIKit

let borderWidth = 1.0
let roundedButtonCornerRadius = 30.0

/// Spacing constants that will be used throughout the app as T-shirt sizes (XS - 4XL)
enum Spacing: CGFloat {
    
    /// Size value: 2
    case spacingXXS = 2
    
    /// Size value: 4
    case spacingXS = 4
    
    /// Size value: 8
    case spacingS = 8
    
    /// Size value: 12
    case spacingM = 12
    
    /// Size value: 16
    case spacingL = 16
    
    /// Size value: 24
    case spacingXL = 24
    
    /// Size value: 32
    case spacingXXL = 32
    
    /// Size value: 64
    case spacing3XL = 64
    
    /// Size value: 128
    case spacing4XL = 128
}

/// Sizing constants
enum Sizing {
    case buttonS
    case buttonM
    case buttonL
    case buttonXL
    case buttonXXL
    
    // Using computing property to scale down buttons on the smaller screen sizes
    var rawValue: CGFloat {
        switch self {
        case .buttonS:
            return UIScreen.screenWidth >= 375 ? 18.0 : 18 * 0.8
        case .buttonM:
            return UIScreen.screenWidth >= 375 ? 24.0 : 24 * 0.8
        case .buttonL:
            return UIScreen.screenWidth >= 375 ? 32 : 32 * 0.8
        case .buttonXL:
            return UIScreen.screenWidth >= 375 ? 48 : 48 * 0.8
        case .buttonXXL:
            return UIScreen.screenWidth >= 375 ? 52 : 52 * 0.8
        }
    }
}

struct Constants {
    
    static let defaultImage = "https://i.imgur.com/X1H8yo3_d.png"
    
    /// URL constants
    struct URL {
        
        // Support email
        static let appSupportEmailAddress = "help@skillr.com"
        
        // Legal section
        static let userHelpSection = "https://skillrhelp.zendesk.com/hc/en-us"
        
    }
    
    struct AppVersion {
        static let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
    
    struct AppBuildNumber {
        static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }
}
