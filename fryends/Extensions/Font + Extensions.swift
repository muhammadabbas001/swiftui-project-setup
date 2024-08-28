//
//  Font.swift
//  Fryends (IOS)
//
//  Created by Muhammad Abbas on 9/13/23.
//

import Foundation
import SwiftUI

extension Font {
    
    static func poppinsRegular(size: CGFloat) -> Font {
        return .custom("Poppins-Regular", size: size)
    }
    
    static func poppinsBold(size: CGFloat) -> Font {
        return .custom("Poppins-Bold", size: size)
    }
    
    static func poppinsMedium(size: CGFloat) -> Font {
        return .custom("Poppins-Medium", size: size)
    }
    
    static func poppinsSemiBold(size: CGFloat) -> Font {
        return .custom("Poppins-SemiBold", size: size)
    }
    
    enum Puppins: String{
        case poppinsBold = "Poppins-Bold"
        case poppinsMedium = "Poppins-Medium"
        case poppinsRegular = "Poppins-Regular"
        case poppinsSemiBold = "Poppins-SemiBold"
        case poppinsLight = "Poppins-Light"
        case italic = "Poppins-Italic"
    }
    
    static func poppins(name: Puppins, size: CGFloat) -> Font {
        return .custom(name.rawValue, size: size)
    }
}
