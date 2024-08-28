//
//  Colors.swift
//  Fryends (IOS)
//
//  Created by Muhammad Abbas on 9/8/23.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    static let themeColor = UIColor(named: "themeColor")
    static let redColor = UIColor(named: "redColor")
    static let switchColor = UIColor(named: "switchColor")
    static let whiteColor = UIColor.white
    static let blackColor = UIColor.black
    static let borderColor = UIColor.black
    static let borderColr = UIColor(named: "borderColor")
}

extension Color {
    static let section = Color("Section")
    static let element = Color("Element")
    static let themeColor = Color("themeColor")
    static let yellow1 = Color("yellow1") // #FFFDF5
    static let borderColor = Color.black
    
    static let primaryBlackGradient = LinearGradient(
        colors: [
            Color(hex: "#D9D9D9").opacity(0),
            .black.opacity(0.72),
            .black
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
