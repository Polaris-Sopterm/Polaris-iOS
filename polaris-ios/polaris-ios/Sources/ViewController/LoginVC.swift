//
//  LoginVC.swift
//  polaris-ios
//
//  Created by USER on 2021/05/23.
//

import UIKit

class LoginVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackgroundView()
        self.setupTextField()
        print(DeviceInfo.bottomSafeAreaInset)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.adjustToDeviceSize()
    }
    
    // MARK: - Set Up
    private func setupBackgroundView() {
        let gradientLayer       = CAGradientLayer()
        gradientLayer.frame     = self.view.bounds
        gradientLayer.locations = [0, 0.5, 1.0]
        gradientLayer.colors    = [
            UIColor(red: 13, green: 17, blue: 42).cgColor,
            UIColor(red: 25, green: 24, blue: 87).cgColor,
            UIColor(red: 60, green: 64, blue: 152).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        
        self.backgroundView.layer.addSublayer(gradientLayer)
        self.backgroundView.subviews.forEach { [weak self] in self?.backgroundView.bringSubviewToFront($0) }
    }
    
    private func setupTextField() {
        let placeHolderFont  = UIFont.systemFont(ofSize: 14, weight: .regular)
        let placeHolderColor = UIColor.white
        
        self.idTextField.attributedPlaceholder = "이메일".attributeString(font: placeHolderFont,
                                                                             textColor: placeHolderColor)
        self.pwTextField.attributedPlaceholder = "비밀번호".attributeString(font: placeHolderFont,
                                                                                textColor: placeHolderColor)
    }
    
    private func adjustToDeviceSize() {
        let gradientLayer = self.backgroundView.layer.sublayers?.first(where: { $0 is CAGradientLayer })
        gradientLayer?.frame = self.view.bounds
        
        self.logoTopConstraint.constant = 72 + DeviceInfo.statusBarHeight
    }
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var logoTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var pwTextField: UITextField!
    
    @IBOutlet private weak var loginButton: PolarisButton!
    @IBOutlet private weak var signupButton: UIButton!
    @IBOutlet private weak var forgetPwButton: UIButton!
    
}
