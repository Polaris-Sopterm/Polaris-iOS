//
//  UILabel+.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/19.
//

import UIKit

extension UILabel {
    
    func setPartialBold(originalText: String,boldText: String,fontSize: CGFloat,boldFontSize: CGFloat){
        let attributedString = NSMutableAttributedString(string: originalText)
        let font = UIFont.systemFont(ofSize: boldFontSize, weight: .bold)
        self.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
        attributedString.addAttribute(.font,value: font,range: (originalText as NSString).range(of: boldText))
        self.attributedText = attributedString
    }
    
    
    
}
