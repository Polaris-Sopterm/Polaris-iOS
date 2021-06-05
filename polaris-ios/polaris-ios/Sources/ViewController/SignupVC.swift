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
        self.observeStepSignup()
        self.observeValidation()
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
    
    private func observeStepSignup() {
        self.viewModel.stepRelay
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] step in
                guard let self = self else { return }
                
                self.updateUI(as: step)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeValidation() {
        self.viewModel.idDuplicatedValidRelay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { validation in
                self.idDuplicatedValidateImageView.image = validation ? #imageLiteral(resourceName: "icnPass") : #imageLiteral(resourceName: "icnError")
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.idFormatValidRelay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { validation in
                self.idFormatValidateImageView.image = validation ? #imageLiteral(resourceName: "icnPass") : #imageLiteral(resourceName: "icnError")
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.pwFormatValidRelay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { validation in
                self.pwFormatValidateImageView.image = validation ? #imageLiteral(resourceName: "icnPass") : #imageLiteral(resourceName: "icnError")
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.pwCountValidRelay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { validation in
                self.pwCountValidateImageView.image = validation ? #imageLiteral(resourceName: "icnPass") : #imageLiteral(resourceName: "icnError")
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.nicknameCountValidRelay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { validation in
                self.nicknameValidateImageView.image = validation ? #imageLiteral(resourceName: "icnPass") : #imageLiteral(resourceName: "icnError")
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeCompleteSignup() {
        self.viewModel.completeSignupSubject
            .subscribe(onNext: { isComplete in
                if isComplete == true {
                    #warning("회원 가입 완료")
                    print("회원 가입 가능")
                } else {
                    print("회원 가입 불가")
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
    
    private func updateValidationViewHiddenState(state: InputOptions, input: String) {
        if state == .id {
            self.idFormatValidateView.isHidden     = input.isEmpty
            self.idDuplicatedValidateView.isHidden = input.isEmpty
        } else if state == .pw {
            self.pwFormatValidateView.isHidden      = input.isEmpty
            self.pwCountValidateView.isHidden      = input.isEmpty
        } else {
            self.nicknameValidateView.isHidden     = input.isEmpty
        }
        
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
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
    @IBOutlet private weak var idDuplicatedValidateView: UIView!
    @IBOutlet private weak var idDuplicatedValidateImageView: UIImageView!
    @IBOutlet private weak var idFormatValidateView: UIView!
    @IBOutlet private weak var idFormatValidateImageView: UIImageView!
    
    @IBOutlet private weak var pwInputContainerView: UIView!
    @IBOutlet private weak var pwTextFieldContainerView: UIView!
    private var pwTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    @IBOutlet private weak var pwCountValidateView: UIView!
    @IBOutlet private weak var pwCountValidateImageView: UIImageView!
    @IBOutlet private weak var pwFormatValidateView: UIView!
    @IBOutlet private weak var pwFormatValidateImageView: UIImageView!
    
    @IBOutlet private weak var nicknameInputContainerView: UIView!
    @IBOutlet private weak var nicknameTextFieldContainerView: UIView!
    private var nicknameTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    @IBOutlet private weak var nicknameValidateView: UIView!
    @IBOutlet private weak var nicknameValidateImageView: UIImageView!
    
}

extension SignupVC: PolarisMarginTextFieldDelegate {
    
    func polarisMarginTextField(_ polarisMarginTextField: PolarisMarginTextField, didChangeText: String) {
        if polarisMarginTextField == self.idTextFieldView {
            self.updateValidationViewHiddenState(state: .id, input: didChangeText)
            self.viewModel.idSubject.onNext(didChangeText)
        } else if polarisMarginTextField == self.pwTextFieldView {
            self.updateValidationViewHiddenState(state: .pw, input: didChangeText)
            self.viewModel.pwSubject.onNext(didChangeText)
        } else {
            self.updateValidationViewHiddenState(state: .nickname, input: didChangeText)
            self.viewModel.nicknameSubject.onNext(didChangeText)
        }
    }
    
    func polarisMarginTextFieldDidTapReturn(_ polarisMarginTextField: PolarisMarginTextField) {
        guard self.viewModel.isLastStep == false else { self.viewModel.processLastStep(); return }
        
        if polarisMarginTextField == self.idTextFieldView {
            self.viewModel.processFirstStep()
        } else if polarisMarginTextField == self.pwTextFieldView {
            self.viewModel.processSecondStep()
        } else {
            self.viewModel.processLastStep()
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
        
        var step: Int? {
            if self == .firstStep       { return 1 }
            else if self == .secondStep { return 2 }
            else if self == .lastStep   { return 3 }
            else                        { return nil }
        }
    }
}
