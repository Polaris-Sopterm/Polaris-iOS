//
//  PolarisMarginTextField.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit
import RxSwift
import RxCocoa

protocol PolarisMarginTextFieldDelegate: class {
    func polarisMarginTextField(_ polarisMarginTextField: PolarisMarginTextField, changedText: String?)
}

class PolarisMarginTextField: UIView {
    weak var delegate: PolarisMarginTextFieldDelegate?
    var text = BehaviorSubject<String>(value: "")
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupMarginView()
        self.bindTextField()
    }
    
    // MARK: - Set Up
    private func setupMarginView() {
        self.clipsToBounds      = true
        self.layer.borderWidth  = 1
        self.layer.cornerRadius = 16
    }
    
    func setupPlaceholder(text: String) {
        self.textField.attributedPlaceholder = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.inactiveTextPurple, .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
    }
    
    // MARK: - Bind
    private func bindTextField() {
        self.textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                if text.isEmpty == true { self.makeDeselectedTextFieldColor() }
                else                    { self.makeSelectedTextFieldColor() }
                
                self.text.onNext(text)
                self.delegate?.polarisMarginTextField(self, changedText: text)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeSelectedTextFieldColor() {
        self.layer.borderColor = self.selectedBorderColor.cgColor
    }
    
    private func makeDeselectedTextFieldColor() {
        self.layer.borderColor = self.deselectedBorderColor.cgColor
    }
    
    @IBInspectable var selectedBorderColor: UIColor     = .mainSky
    @IBInspectable var deselectedBorderColor: UIColor   = .clear
    
    @IBOutlet weak var textField: UITextField!
    
    var disposeBag = DisposeBag()
}