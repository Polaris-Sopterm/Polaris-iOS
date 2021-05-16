//
//  AddButton.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit

class AddButton: UIButton {
    
    @IBInspectable var enableBackgroundColor: UIColor   = .mainSky
    @IBInspectable var disableBackgroundColor: UIColor  = .inactiveBtn
    @IBInspectable var enableTextColor: UIColor         = .white
    @IBInspectable var disableTextColor: UIColor        = .inactiveText
    @IBInspectable var enable: Bool                     = false {
        didSet {
            if self.enable == true  { self.makeEnable() }
            else                    { self.makeDisable() }
        }
    }

    // MARK: - Life Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
    }
    
    private func makeEnable() {
        self.backgroundColor            = self.enableBackgroundColor
        self.setTitleColor(self.enableTextColor, for: .normal)
        self.isUserInteractionEnabled   = true
    }
    
    private func makeDisable() {
        self.backgroundColor            = self.disableBackgroundColor
        self.setTitleColor(self.disableTextColor, for: .normal)
        self.isUserInteractionEnabled   = false
    }
    
}
