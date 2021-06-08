//
//  TermsOfServiceView.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/06.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class TermsOfServiceView: UIView {
    
    typealias Completion = () -> Void
    var completion: Completion?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupButtons()
        self.bindButtons()
        self.bindTapGesture()
        self.bindCheck()
    }
    
    func presentPopupView(from viewController: UIViewController) {
        viewController.view.addSubview(self)
        self.snp.makeConstraints { make in make.edges.equalToSuperview() }
        self.animateForPresent()
    }
    
    private func dismissPopupView(completion: Completion? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.termsView.transform = CGAffineTransform(translationX: 0, y: 290)
            self.dimView.alpha       = 0
        }) { _ in
            completion?()
            self.removeFromSuperview()
        }
    }
    
    private func setupButtons() {
        let singleLinePersonalText = NSAttributedString(string: "개인정보 수집이용 동의", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.personalTermDescButton.setAttributedTitle(singleLinePersonalText, for: .normal)
        
        let singleLineServicetext = NSAttributedString(string: "서비스 이용약관 동의", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.serviceTermDescButton.setAttributedTitle(singleLineServicetext, for: .normal)
    }
    
    private func animateForPresent() {
        self.dimView.alpha       = 0
        self.termsView.transform = CGAffineTransform(translationX: 0, y: 290)
        
        UIView.animate(withDuration: 0.3) {
            self.dimView.alpha       = 1
            self.termsView.transform = .identity
        }
    }
    
    private func bindTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] recognizer in
                self?.dismissPopupView()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindButtons() {
        self.closeButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.dismissPopupView()
            })
            .disposed(by: self.disposeBag)
        
        self.personalTermCheckButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let check = self.checkPersonalRelay.value
                
                self.checkPersonalRelay.accept(!check)
            })
            .disposed(by: self.disposeBag)
        
        self.serviceTermCheckButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let check = self.checkServiceRelay.value
                
                self.checkServiceRelay.accept(!check)
            })
            .disposed(by: self.disposeBag)
        
        self.completeButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.dismissPopupView(completion: self?.completion)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindCheck() {
        Observable.combineLatest(self.checkPersonalRelay, self.checkServiceRelay)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { personalCheck, serviceCheck in
                self.completeButton.isUserInteractionEnabled = personalCheck && serviceCheck
                self.completeButton.backgroundColor = personalCheck && serviceCheck ? .mainSky : .inactiveText
                
                self.serviceTermCheckButton.setImage(serviceCheck ? #imageLiteral(resourceName: "btnCheck") : #imageLiteral(resourceName: "btnUncheck"), for: .normal)
                self.personalTermCheckButton.setImage(personalCheck ? #imageLiteral(resourceName: "btnCheck") : #imageLiteral(resourceName: "btnUncheck"), for: .normal)
            })
            .disposed(by: self.disposeBag)
    }
    
    private var disposeBag = DisposeBag()
    private var checkPersonalRelay = BehaviorRelay<Bool>(value: false)
    private var checkServiceRelay  = BehaviorRelay<Bool>(value: false)

    @IBOutlet private weak var dimView: UIView!
    @IBOutlet private weak var termsView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var personalTermCheckButton: UIButton!
    @IBOutlet private weak var personalTermButton: UIButton!
    @IBOutlet private weak var personalTermDescButton: UIButton!
    @IBOutlet private weak var serviceTermCheckButton: UIButton!
    @IBOutlet private weak var serviceTermButton: UIButton!
    @IBOutlet private weak var serviceTermDescButton: UIButton!
    @IBOutlet private weak var completeButton: UIButton!
    
}
