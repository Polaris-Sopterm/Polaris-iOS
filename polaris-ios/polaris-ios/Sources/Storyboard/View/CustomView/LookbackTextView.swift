//
//  LookbackTextView.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/01/13.
//

import UIKit

class LookbackTextView: UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {        
        return true
    }
}
