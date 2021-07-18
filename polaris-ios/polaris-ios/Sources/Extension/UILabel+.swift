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
    
    func setLineSpacing(spacing: CGFloat) {
        let attributedString = NSMutableAttributedString(string: "Your text")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
    
}
