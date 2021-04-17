//
//  AddButton.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit

@IBDesignable
class AddButton: UIButton {
    @IBInspectable var enableBackgroundColor: UIColor   = .mainSky
    @IBInspectable var disableBackgroundColor: UIColor  = .inactiveBtn
    
    @IBInspectable var cornerRadius: CGFloat = 18 {
        didSet { self.makeRoundCorner(directions: .allCorners, radius: self.cornerRadius) }
    }

    // MARK: - Life Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func makeEnable() {
        self.backgroundColor            = self.enableBackgroundColor
        self.isUserInteractionEnabled   = true
    }
    
    private func makeDisable() {
        self.backgroundColor            = self.disableBackgroundColor
        self.isUserInteractionEnabled   = false
    }
    
    var enable: Bool = false {
        didSet {
            if self.enable  { self.makeEnable() }
            else            { self.makeDisable() }
        }
    }
}
