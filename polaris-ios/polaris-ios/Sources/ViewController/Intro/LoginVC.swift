//
//  LoginVC.swift
//  polaris-ios
//
//  Created by USER on 2021/05/23.
//

import RxCocoa
import RxSwift
import UIKit

final class LoginVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackgroundView()
        self.setupLoadingView()
        self.setupCometAnimation()
        self.setupLogoTopConstraint()
        self.setupTextField()
        self.setupObserver()
        self.addKeyboardDismissTapGesture()
        self.bindTextFields()
        self.bindButtons()
        self.observeViewModel()
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
    
    private func setupLoadingView() {
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.loadingView.addSubview(self.loadingIndicator)
        self.loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.stopLoadingIndicator()
    }
    
    private func setupLogoTopConstraint() {
        self.logoTopConstraint.constant = type(of: self).logoTopConstraintValue
    }
    
    private func setupTextField() {
        let placeHolderFont  = UIFont.systemFont(ofSize: 14, weight: .regular)
        let placeHolderColor = UIColor.white
        
        self.idTextField.attributedPlaceholder = "이메일".attributeString(font: placeHolderFont,
                                                                             textColor: placeHolderColor)
        self.pwTextField.attributedPlaceholder = "비밀번호".attributeString(font: placeHolderFont,
                                                                                textColor: placeHolderColor)
    }
    
    private func setupObserver() {
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(self.animateViewForKeyboardShow(_:)),
                           name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(self.animateViewForKeyboardHide(_:)),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupCometAnimation() {
        (0...2).forEach { _ in self.startCometAnimation() }
    }
    
    private func startCometAnimation() {
        guard let cometType = ShootingComet.allCases.randomElement() else { return }
        
        let yPosition = CGFloat(Int.random(in: 0...400))
        let duration  = Double(Int.random(in: 15...60)) / 10.0
        
        let cometImageView   = UIImageView(image: cometType.starImage)
        cometImageView.frame = CGRect(x: DeviceInfo.screenWidth, y: yPosition, width: cometType.size, height: cometType.size)
        self.view.addSubview(cometImageView)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            cometImageView.transform = CGAffineTransform(translationX: -DeviceInfo.screenWidth - 120, y: DeviceInfo.screenWidth + 120)
        }, completion: { [weak self] finished in
            guard finished == true else { return }
            
            cometImageView.removeFromSuperview()
            self?.startCometAnimation()
        })
    }
    
    private func startLoadingIndicator() {
        self.loadingView.isHidden = false
        self.loadingIndicator.startAnimating()
    }
    
    private func stopLoadingIndicator() {
        self.loadingView.isHidden = true
        self.loadingIndicator.stopAnimating()
    }
    
    private func adjustToDeviceSize() {
        let gradientLayer = self.backgroundView.layer.sublayers?.first(where: { $0 is CAGradientLayer })
        gradientLayer?.frame = self.view.bounds
    }
    
    @objc func animateViewForKeyboardShow(_ notification: NSNotification) {
        guard self == UIViewController.getVisibleController() else { return }
        
        self.animateWithKeyboard(notification) { [weak self] _, keyboardDuration in
            guard let self = self                         else { return }
            guard let keyboardDuration = keyboardDuration else { return }
            
            self.layoutForKeyboardShow()
            UIView.animate(withDuration: keyboardDuration) { self.view.layoutIfNeeded() }
        }
    }
    
    @objc func animateViewForKeyboardHide(_ notification: NSNotification) {
        guard self == UIViewController.getVisibleController() else { return }
        
        self.animateWithKeyboard(notification) { [weak self] _, keyboardDuration in
            guard let self = self                         else { return }
            guard let keyboardDuration = keyboardDuration else { return }
            
            self.layoutForKeyboardHide()
            UIView.animate(withDuration: keyboardDuration) { self.view.layoutIfNeeded() }
        }
    }
    
    private func presentSignup() {
        guard let signupViewController = SignupVC.instantiateFromStoryboard(StoryboardName.intro) else { return }
        signupViewController.modalPresentationStyle = .overFullScreen
        self.present(signupViewController, animated: true) {
            self.layoutForKeyboardHide()
        }
    }
    
    private func bindTextFields() {
        Observable.merge([self.idTextField.rx.controlEvent(.editingDidBegin).asObservable(),
                          self.pwTextField.rx.controlEvent(.editingDidBegin).asObservable()])
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.idTextContainerView.borderColor = self.idTextField.isFirstResponder ? .white : .clear
                self.pwTextContainerView.borderColor = self.pwTextField.isFirstResponder ? .white : .clear
            })
            .disposed(by: self.disposeBag)
        
        Observable.merge([self.idTextField.rx.controlEvent(.editingDidEnd).asObservable(),
                          self.pwTextField.rx.controlEvent(.editingDidEnd).asObservable()])
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.idTextContainerView.borderColor = self.idTextField.isFirstResponder ? .white : .clear
                self.pwTextContainerView.borderColor = self.pwTextField.isFirstResponder ? .white : .clear
            })
            .disposed(by: self.disposeBag)
        
        self.idTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                self.viewModel.idSubject.onNext(text)
            })
            .disposed(by: self.disposeBag)
        
        self.pwTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                self.viewModel.pwSubject.onNext(text)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindButtons() {
        self.signupButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.presentSignup()
            })
            .disposed(by: self.disposeBag)
        
        self.loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.requestLogin()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeViewModel() {
        self.viewModel.canProcessLoginSubject
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isProceed in
                guard let self = self else { return }
                
                if isProceed == true { self.loginButton.enable = true  }
                else                 { self.loginButton.enable = false }
            }).disposed(by: self.disposeBag)
        
        self.viewModel.completeLoginSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                guard let mainVC = MainVC.instantiateFromStoryboard(StoryboardName.main) else { return }
                UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController = mainVC
            }).disposed(by: self.disposeBag)
        
        self.viewModel.loadingSubject.observeOnMain(onNext: { [weak self] loading in
            loading ? self?.startLoadingIndicator() : self?.stopLoadingIndicator()
        }).disposed(by: self.disposeBag)
    }
    
    private func layoutForKeyboardHide() {
        self.logoTopConstraint.constant      = type(of: self).logoTopConstraintValue
        self.textFieldTopConstraint.constant = type(of: self).textFieldTopConstraintValue
    }
    
    private func layoutForKeyboardShow() {
        self.logoTopConstraint.constant      = type(of: self).logoTopConstraintValue - DeviceInfo.topSafeAreaInset - 20
        self.textFieldTopConstraint.constant = type(of: self).textFieldTopConstraintValue - 70
    }
    
    private static let logoTopConstraintValue: CGFloat      = 72 + DeviceInfo.topSafeAreaInset
    private static let textFieldTopConstraintValue: CGFloat = 77
    
    private var disposeBag = DisposeBag()
    private var viewModel  = LoginViewModel()
    
    private let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let loadingView: UIView                       = UIView(frame: .zero)
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var logoTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var textFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var idTextContainerView: UIView!
    @IBOutlet private weak var pwTextField: UITextField!
    @IBOutlet private weak var pwTextContainerView: UIView!
    
    @IBOutlet private weak var loginButton: PolarisButton!
    @IBOutlet private weak var signupButton: UIButton!
    @IBOutlet private weak var forgetPwButton: UIButton!
    
}
