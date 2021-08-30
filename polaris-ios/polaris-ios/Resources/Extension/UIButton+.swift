//
//  UIButton+.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/27.
//

import UIKit

extension UIButton {
    
    @IBInspectable var imageTintColor: UIColor {
        set {
            let currentImage = self.image(for: .normal)
            let templateImage = currentImage?.withRenderingMode(.alwaysTemplate)
            self.setImage(templateImage, for: .normal)
            self.tintColor = newValue
        }
        
        get {
            return self.tintColor
        }
    }
    
}
