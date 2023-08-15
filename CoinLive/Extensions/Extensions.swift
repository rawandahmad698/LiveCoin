//
//  Extensions.swift
//  CoinLive
//
//  Created by Rawand Ahmad on 15/08/2023.
//

import UIKit


extension UIView {
    func setBorderWithHexColor(hexColor: String, borderWidth: CGFloat) {
        let borderColor = UIColor(hex: hexColor)
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UILabel {
    func formatCurrency(amount: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "$"
        numberFormatter.maximumFractionDigits = 4 // Adjust this as needed
        
        self.text = numberFormatter.string(from: NSNumber(value: Double(amount) ?? 0.0))
    }
}
