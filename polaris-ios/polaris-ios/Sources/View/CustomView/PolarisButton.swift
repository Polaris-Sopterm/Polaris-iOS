//
//  PolarisButton.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit

class PolarisButton: UIButton {
    
    @IBInspectable var enableBackgroundColor: UIColor   = .mainSky
    @IBInspectable var disableBackgroundColor: UIColor  = .inactiveBtn
    @IBInspectable var enableTextColor: UIColor         = .white
    @IBInspectable var disableTextColor: UIColor        = .inactiveText
    @IBInspectable var enable: Bool                     = false {
        didSet {
            self.adjustButton(as: self.enable)
        }
    }

    // MARK: - Life Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adjustButton(as: self.enable)
    }
    
    private func adjustButton(as enable: Bool) {
        if enable == true { self.makeEnable()  }
        else              { self.makeDisable() }
    }
    
    private func makeEnable() {
        self.isUserInteractionEnabled   = true
        self.backgroundColor            = self.enableBackgroundColor
        self.setTitleColor(self.enableTextColor, for: .normal)
    }
    
    private func makeDisable() {
        self.isUserInteractionEnabled   = false
        self.backgroundColor            = self.disableBackgroundColor
        self.setTitleColor(self.disableTextColor, for: .normal)
    }
    
}
