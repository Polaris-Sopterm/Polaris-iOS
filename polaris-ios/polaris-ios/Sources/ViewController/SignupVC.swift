//
//  SignupVC.swift
//  polaris-ios
//
//  Created by USER on 2021/05/23.
//

import RxCocoa
import RxSwift
import UIKit

class SignupVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeyboardDismissTapGesture()
        self.adjustTopConstraint()
        self.setupTextFields()
    }
    
    private func setupTextFields() {
        guard let idTextFieldView       = self.idTextFieldView,
              let pwTextFieldView       = self.pwTextFieldView,
              let nicknameTextFieldView = self.nicknameTextFieldView else { return }
        
        self.idTextFieldContainerView.addSubview(idTextFieldView)
        self.pwTextFieldContainerView.addSubview(pwTextFieldView)
        self.nicknameTextFieldContainerView.addSubview(nicknameTextFieldView)
        
        idTextFieldView.delegate       = self
        pwTextFieldView.delegate       = self
        nicknameTextFieldView.delegate = self
    }
    
    private func adjustTopConstraint() {
        let defaultTopConstraint: CGFloat = 46
        
        self.idDescriptionTopConstraint.constant = defaultTopConstraint + DeviceInfo.topSafeAreaInset
        self.pwDescriptionTopConstraint.constant = defaultTopConstraint + DeviceInfo.topSafeAreaInset
        self.nicknameTopConstraint.constant      = defaultTopConstraint + DeviceInfo.topSafeAreaInset
    }
    
    @IBOutlet private weak var idDescriptionStackView: UIStackView!
    @IBOutlet private weak var pwDescriptionStackView: UIStackView!
    @IBOutlet private weak var nicknameDescriptionStackView: UIStackView!
    @IBOutlet private weak var idDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pwDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nicknameTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var idTextFieldContainerView: UIView!
    private var idTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    
    @IBOutlet private weak var pwTextFieldContainerView: UIView!
    private var pwTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    
    @IBOutlet private weak var nicknameTextFieldContainerView: UIView!
    private var nicknameTextFieldView: PolarisMarginTextField? = UIView.fromNib()
}

extension SignupVC: PolarisMarginTextFieldDelegate {
    
    func polarisMarginTextField(_ polarisMarginTextField: PolarisMarginTextField, didChangeText: String) {
        print(didChangeText)
    }
    
}
