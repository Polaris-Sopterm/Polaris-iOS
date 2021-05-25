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

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeyboardDismissTapGesture()
        self.adjustTopConstraint()
        self.setupTextFields()
        self.observeInputState()
        self.observeValidateInputs()
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
    
    private func observeInputState() {
        self.viewModel.totalInputStateRelay
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] inputState in
                guard let self = self          else { return }
                
                if inputState == .firstStep {
                    self.idInputContainerView.isHidden       = false
                    self.pwInputContainerView.isHidden       = true
                    self.nicknameInputContainerView.isHidden = true
                } else if inputState == .secondStep {
                    self.pwInputContainerView.alpha    = 0
                    self.pwInputContainerView.isHidden = false
                } else if inputState == .lastStep {
                    self.nicknameInputContainerView.alpha    = 0
                    self.nicknameInputContainerView.isHidden = false
                }
                
                guard inputState != .firstStep else { return }
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                    [self.pwInputContainerView, self.nicknameInputContainerView].forEach { $0?.alpha = 1 }
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeValidateInputs() {
        self.viewModel.validateIdSubejct
            .distinctUntilChanged()
            .do(onNext: { [weak self] validate in
                guard let self = self else { return }
                
                switch validate {
                case .empty:         self.idValidateView.isHidden = true
                case .validation(_): self.idValidateView.isHidden = false
                }
                
                UIView.animate(withDuration: 0.3) { [weak self] in self?.view.layoutIfNeeded() }
            })
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] validate in
                guard let self = self else { return }
                
                guard self.viewModel.isProcessableFirstStep(validate) == true else { return }
                self.viewModel.totalInputStateRelay.accept(.secondStep)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.validatePwSubject
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] validate in
                guard let self = self else { return }
                
                let currentInputState = self.viewModel.totalInputStateRelay.value
                
                guard validate == true, currentInputState == .secondStep else { return }
                self.viewModel.totalInputStateRelay.accept(.lastStep)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.validateNicknameSubject
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] validate in
                guard let self = self else { return }
                
                defer { /* 닉네임 유효성 체크하는 부분 추가 */ }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateValidateUI(_ option: InputOptions, as validate: Bool) {
        
    }
    
    private var disposeBag = DisposeBag()
    private var viewModel  = SignupViewModel()
    
    @IBOutlet private weak var idDescriptionStackView: UIStackView!
    @IBOutlet private weak var pwDescriptionStackView: UIStackView!
    @IBOutlet private weak var nicknameDescriptionStackView: UIStackView!
    @IBOutlet private weak var idDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pwDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nicknameTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var idInputContainerView: UIView!
    @IBOutlet private weak var idTextFieldContainerView: UIView!
    private var idTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    @IBOutlet private weak var idValidateView: UIView!
    
    @IBOutlet private weak var pwInputContainerView: UIView!
    @IBOutlet private weak var pwTextFieldContainerView: UIView!
    private var pwTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    @IBOutlet private weak var pwCountValidateView: UIView!
    @IBOutlet private weak var pwCombiValidateView: UIView!
    
    @IBOutlet private weak var nicknameInputContainerView: UIView!
    @IBOutlet private weak var nicknameTextFieldContainerView: UIView!
    private var nicknameTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    @IBOutlet private weak var nicknameValidateView: UIView!
    
}

extension SignupVC: PolarisMarginTextFieldDelegate {
    
    func polarisMarginTextField(_ polarisMarginTextField: PolarisMarginTextField, didChangeText: String) {
        if polarisMarginTextField == self.idTextFieldView {
            self.viewModel.idSubject.onNext(didChangeText)
        } else if polarisMarginTextField == self.pwTextFieldView {
            self.viewModel.pwSubject.onNext(didChangeText)
        } else {
            self.viewModel.nicknameSubject.onNext(didChangeText)
        }
    }
    
}


extension SignupVC {
    struct InputOptions: OptionSet {
        let rawValue: Int
        
        static let id       = InputOptions(rawValue: 1 << 0)
        static let pw       = InputOptions(rawValue: 1 << 1)
        static let nickname = InputOptions(rawValue: 1 << 2)
        
        static let firstStep: InputOptions  = [.id]
        static let secondStep: InputOptions = [.id, .pw]
        static let lastStep: InputOptions   = [.id, .pw, .nickname]
    }
}
