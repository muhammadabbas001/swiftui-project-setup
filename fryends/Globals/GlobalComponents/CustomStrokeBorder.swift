//
//  CustomStrokeBorder.swift
//  Fryends (IOS)
//
//  Created by Muhammad Abbas on 08/08/2024.
//

import SwiftUI

struct CustomStrokeShape: Shape {
    var cornerRadius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        return Path(path.cgPath)
    }
}

struct CustomStrokeBorder: ViewModifier {
    var cornerRadius: CGFloat
    var corners: UIRectCorner
    var lineWidth: CGFloat
    var strokeColor: Color
    
    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { geometry in
                CustomStrokeShape(cornerRadius: cornerRadius, corners: corners)
                    .stroke(strokeColor, lineWidth: lineWidth)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        )
    }
}

extension View {
    func customStrokeBorder(cornerRadius: CGFloat, corners: UIRectCorner, lineWidth: CGFloat, strokeColor: Color) -> some View {
        self.modifier(CustomStrokeBorder(cornerRadius: cornerRadius, corners: corners, lineWidth: lineWidth, strokeColor: strokeColor))
    }
}
