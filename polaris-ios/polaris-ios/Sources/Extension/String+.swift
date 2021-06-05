//
//  String+.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/19.
//

import UIKit

extension String {
   
    func makeStarImageName(starName: String,level: Int) -> String{
        let category = StarNames.starDict[starName] ?? "Happiness"
        return "img"+category+"0"+String(level)
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
    
    func containsCharacterSet(_ set: CharacterSet) -> Bool {
        for character in self {
            let characterSet = CharacterSet(charactersIn: String(character))
            if set.isSuperset(of: characterSet) == true { return true }
        }
        return false
    }
    
    func isEmailFormat() -> Bool {
        let emailPattern: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let regex = try? NSRegularExpression(pattern: emailPattern, options: [])
        let matchNumber = regex?.numberOfMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self))
        return matchNumber != 0
    }
    
}
