//
//  String+.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/19.
//

import UIKit

extension String {
    
    static func makeStarImageName(starName: String, level: Int) -> String{
        let category = StarNames.starDict[starName] ?? "Happiness"
        return "img"+category+"0"+String(level)
    }
    
    func subRange(of text: String) -> NSRange {
        return (self as NSString).range(of: text)
    }
    
    func attributeString(font: UIFont?, textColor: UIColor?) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        let stringRange     = (self as NSString).range(of: self)
        
        if let font = font {
            attributeString.addAttribute(.font, value: font, range: stringRange)
        }
        
        if let textColor = textColor {
            attributeString.addAttribute(.foregroundColor, value: textColor, range: stringRange)
        }
        
        return attributeString
    }
    
    func isEmailFormat() -> Bool {
        let emailPattern: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let regex = try? NSRegularExpression(pattern: emailPattern, options: [])
        let matchNumber = regex?.numberOfMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self))
        return matchNumber != 0
    }
    
    func isPasswordFormat() -> Bool {
        let digitFormat: String    = "[0-9]"
        let alphabetFormat: String = "[a-zA-Z]"
        
        let digitRegex = try? NSRegularExpression(pattern: digitFormat, options: [])
        let alphaRegex = try? NSRegularExpression(pattern: alphabetFormat, options: [])
        
        return digitRegex?.numberOfMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) != 0 &&
            alphaRegex?.numberOfMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) != 0
    }
    
    func convertToDate(_ format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.date(from: self)
    }
    
}
