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
        self.bindCloseButton()
        self.observeInputState()
        self.observeValidateInputs()
        self.observeCompleteSignup()
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
        let defaultTopConstraint: CGFloat = 11
        
        self.closeButtonTopConstraint.constant = defaultTopConstraint + DeviceInfo.topSafeAreaInset
    }
    
    private func observeInputState() {
        self.viewModel.stepRelay
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] inputState in
                guard let self = self else { return }
                
                self.updateUI(as: inputState)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeValidateInputs() {
        var isFirst: Bool = true
        
        self.viewModel.validateIdSubejct
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] validate in
                guard let self = self else { return }
                
                self.updateIdValidateUI(as: validate)
                
                guard isFirst == false else { isFirst = false; return }
                UIView.animate(withDuration: 0.3) { [weak self] in self?.view.layoutIfNeeded() }
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.validatePwSubject
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] validate in
                guard let self = self else { return }
                
                self.updatePwValidateUI(as: validate)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.validateNicknameSubject
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] validate in
                guard let self = self else { return }
                
                self.updateNicknameValidateUI(as: validate)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeCompleteSignup() {
        self.viewModel.completeSignupSubject
            .subscribe(onNext: { isComplete in
                if isComplete == true {
                    #warning("회원 가입 완료")
                } else {
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindCloseButton() {
        self.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateUI(as state: InputOptions) {
        self.idInputContainerView.isHidden       = state.contains(.id) ? false : true
        self.pwInputContainerView.isHidden       = state.contains(.pw) ? false : true
        self.nicknameInputContainerView.isHidden = state.contains(.nickname) ? false : true
        
        [self.idDescriptionStackView, self.pwDescriptionStackView, self.nicknameDescriptionStackView].enumerated().forEach { index, descriptionView in
            guard let step = state.step else { return }
            
            descriptionView?.isHidden = (index + 1) == step ? false : true
        }
        
        guard state != .firstStep else { return }
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut]) { self.view.layoutIfNeeded() }
    }
    
    private func updateIdValidateUI(as state: IdValidateState) {
        switch state {
        case .validation(let validate): self.idValidateImageView.image = validate ? #imageLiteral(resourceName: "icnPass") : #imageLiteral(resourceName: "icnError")
        case .empty: break
        }
        
        self.idValidateView.isHidden = state == .empty
    }
    
    private func updatePwValidateUI(as state: PwValidateState) {
        guard self.viewModel.isFirstStep == false else { return }
        
        switch state {
        case .allValidation(let isAll):
            self.pwCountValidateImageView.image = isAll ? #imageLiteral(resourceName: "icnPass") : #imageLiteral(resourceName: "icnError")
            self.pwCombiValidateImageView.image = isAll ? #imageLiteral(resourceName: "icnPass") : #imageLiteral(resourceName: "icnError")
        case .eachValidation(let invalidType):
            self.pwCombiValidateImageView.image = (invalidType == .combi) ? #imageLiteral(resourceName: "icnError") : #imageLiteral(resourceName: "icnPass")
            self.pwCountValidateImageView.image = (invalidType == .count) ? #imageLiteral(resourceName: "icnError") : #imageLiteral(resourceName: "icnPass")
        default: break
        }
        
        self.pwCombiValidateView.isHidden = state == .empty
        self.pwCountValidateView.isHidden = state == .empty
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    private func updateNicknameValidateUI(as state: NicknameValidateState) {
        guard self.viewModel.isFirstStep == false else { return }
        
        switch state {
        case .validation(let validate): self.nicknameValidateImageView.image = validate ? #imageLiteral(resourceName: "icnPass") : #imageLiteral(resourceName: "icnError")
        case .empty: break
        }
        
        self.nicknameValidateView.isHidden = state == .empty
        UIView.animate(withDuration: 0.3) { [weak self] in self?.view.layoutIfNeeded() }
    }
    
    private var disposeBag = DisposeBag()
    private var viewModel  = SignupViewModel()
    
    @IBOutlet private weak var idDescriptionStackView: UIStackView!
    @IBOutlet private weak var pwDescriptionStackView: UIStackView!
    @IBOutlet private weak var nicknameDescriptionStackView: UIStackView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var closeButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var idInputContainerView: UIView!
    @IBOutlet private weak var idTextFieldContainerView: UIView!
    private var idTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    @IBOutlet private weak var idValidateView: UIView!
    @IBOutlet private weak var idValidateImageView: UIImageView!
    
    @IBOutlet private weak var pwInputContainerView: UIView!
    @IBOutlet private weak var pwTextFieldContainerView: UIView!
    private var pwTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    @IBOutlet private weak var pwCountValidateView: UIView!
    @IBOutlet private weak var pwCountValidateImageView: UIImageView!
    @IBOutlet private weak var pwCombiValidateView: UIView!
    @IBOutlet private weak var pwCombiValidateImageView: UIImageView!
    
    @IBOutlet private weak var nicknameInputContainerView: UIView!
    @IBOutlet private weak var nicknameTextFieldContainerView: UIView!
    private var nicknameTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    @IBOutlet private weak var nicknameValidateView: UIView!
    @IBOutlet private weak var nicknameValidateImageView: UIImageView!
    
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
    
    func polarisMarginTextFieldDidTapReturn(_ polarisMarginTextField: PolarisMarginTextField) {
        if polarisMarginTextField == self.idTextFieldView { self.processFirstStep() }
        else if polarisMarginTextField == self.pwTextFieldView { self.processSecondStep() }
        else { self.processLastStep() }
    }
    
    private func processFirstStep() {
        guard self.viewModel.isLastStep == false            else { self.viewModel.confirmCompleteSignup(); return }
        guard self.viewModel.isProcessableFirstStep == true else { return }
        self.pwTextFieldView?.becomeKeyboardFirstResponder()
        self.viewModel.stepRelay.accept(.secondStep)
    }
    
    private func processSecondStep() {
        guard self.viewModel.isLastStep == false             else { self.viewModel.confirmCompleteSignup(); return }
        guard self.viewModel.isProcessableSecondStep == true else { return }
        self.nicknameTextFieldView?.becomeKeyboardFirstResponder()
        self.viewModel.stepRelay.accept(.lastStep)
    }
    
    private func processLastStep() {
        guard self.viewModel.isLastStep == true else { return }
        self.viewModel.confirmCompleteSignup()
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
        
        var step: Int? {
            if self == .firstStep       { return 1 }
            else if self == .secondStep { return 2 }
            else if self == .lastStep   { return 3 }
            else                        { return nil }
        }
    }
}
