//
//  UIColor+.swift
//  polaris-ios
//
//  Created by USER on 2021/04/11.
//

import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        let scanner = Scanner(string: hexString)
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x00000000000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red     = CGFloat(r) / 255.0
        let green   = CGFloat(g) / 255.0
        let blue    = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: alpha)
    }
}

extension UIColor {
    @nonobjc class var maintext: UIColor {
        return UIColor(red: 64.0 / 255.0, green: 64.0 / 255.0, blue: 140.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var mainPurple: UIColor {
        return UIColor(red: 105.0 / 255.0, green: 105.0 / 255.0, blue: 192.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var inactiveBtn: UIColor {
        return UIColor(red: 240.0 / 255.0, green: 243.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var field: UIColor {
        return UIColor(white: 250.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var inactiveSky: UIColor {
        return UIColor(red: 229.0 / 255.0, green: 248.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var inactiveTextSky: UIColor {
        return UIColor(red: 185.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var mainSky: UIColor {
        return UIColor(red: 127.0 / 255.0, green: 219.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var inactivePurple: UIColor {
        return UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var inactiveText: UIColor {
        return UIColor(red: 203.0 / 255.0, green: 212.0 / 255.0, blue: 212.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var textSky: UIColor {
        return UIColor(red: 104.0 / 255.0, green: 199.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var inactiveTextPurple: UIColor {
        return UIColor(red: 198.0 / 255.0, green: 198.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var darkBlue10: UIColor {
        return UIColor(red: 0.0, green: 0.0, blue: 102.0 / 255.0, alpha: 0.1)
    }
    @nonobjc class var white70: UIColor {
        return UIColor(white: 1.0, alpha: 0.7)
    }
    @nonobjc class var lightblue: UIColor {
        return UIColor(red: 137.0 / 255.0, green: 211.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var bubblegumPink: UIColor {
        return UIColor(red: 1.0, green: 149.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var white60: UIColor {
        return UIColor(white: 1.0, alpha: 0.6)
    }
    @nonobjc class var white40: UIColor {
      return UIColor(white: 1.0, alpha: 0.4)
    }
    
}
