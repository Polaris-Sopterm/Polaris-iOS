//
//  UITextField+.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/08/23.
//

import Foundation
import UIKit

extension UITextField {
    func addLeftPadding(left: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
