//
//  PolarisMarginTextField.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/04/18.
//

import UIKit
import RxSwift
import RxCocoa

protocol PolarisMarginTextFieldDelegate: AnyObject {
    func polarisMarginTextField(_ polarisMarginTextField: PolarisMarginTextField, didChangeText: String)
    func polarisMarginTextFieldDidTapReturn(_ polarisMarginTextField: PolarisMarginTextField)
}

class PolarisMarginTextField: UIView {
    
    @IBInspectable var selectedBorderColor: UIColor     = .mainSky
    @IBInspectable var unselectedBorderColor: UIColor   = .clear
    
    weak var delegate: PolarisMarginTextFieldDelegate?
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupMarginView()
        self.bindTextField()
    }
    
    func setPlaceholder(text: String) {
        self.textField.attributedPlaceholder = NSMutableAttributedString(string: text,
                                                                         attributes: [.foregroundColor: UIColor.inactiveTextPurple, .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
    }
    
    func setText(_ text: String) {
        self.textField.text = text
    }
    
    func setScure(_ isSecure: Bool) {
        self.textField.isSecureTextEntry = isSecure
    }
    
    func setKeyboardReturnType(_ returnType: UIReturnKeyType) {
        self.textField.returnKeyType = returnType
    }
    
    func setKeyboardType(_ keyboardType: UIKeyboardType) {
        self.textField.keyboardType = keyboardType
    }
    
    func becomeKeyboardFirstResponder() {
        self.textField.becomeFirstResponder()
    }
    
    func resignKeyboardFirstResponder() {
        self.textField.resignFirstResponder()
    }
    
    // MARK: - Set Up
    private func setupMarginView() {
        self.clipsToBounds      = true
        self.layer.borderWidth  = 1
        self.layer.borderColor  = self.unselectedBorderColor.cgColor
        self.layer.cornerRadius = 16
    }
    
    // MARK: - Bind
    private func bindTextField() {
        self.textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                self?.makeSelectedTextFieldColor()
            })
            .disposed(by: self.disposeBag)
        
        self.textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                self?.makeDeselectedTextFieldColor()
            })
            .disposed(by: self.disposeBag)
        
        self.textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                self.delegate?.polarisMarginTextField(self, didChangeText: text)
            })
            .disposed(by: self.disposeBag)
        
        self.textField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.polarisMarginTextFieldDidTapReturn(self)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeSelectedTextFieldColor() {
        self.layer.borderColor = self.selectedBorderColor.cgColor
    }
    
    private func makeDeselectedTextFieldColor() {
        self.layer.borderColor = self.unselectedBorderColor.cgColor
    }
    
    private var disposeBag = DisposeBag()
    
    @IBOutlet private weak var textField: UITextField!
    
}
