//
//  UILabel+.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/19.
//

import UIKit

extension UILabel {
    
    func setPartialBold(boldText: String,fontSize: CGFloat){
        let text = self.text ?? ""
        let attributedString = NSMutableAttributedString(string: text)
        let font = UIFont.systemFont(ofSize: 23, weight: .bold)
        self.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
        attributedString.addAttribute(.font,value: font,range: (text as NSString).range(of: boldText))
        self.attributedText = attributedString
    }
    
    
    
}
