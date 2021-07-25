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

protocol TermsOfServiceDelegate: AnyObject {
    func termsOfServiceViewDidTapPersonalTerm(_ termsOfServiceView: TermsOfServiceView)
    func termsOfServiceViewDidTapServiceTerm(_ termsOfServiceView: TermsOfServiceView)
    func termsOfServiceViewDidTapComplete(_ termsOfServiceView: TermsOfServiceView)
}

class TermsOfServiceView: UIView {
    
    weak var delegate: TermsOfServiceDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
        self.bindTapGesture()
        self.bindCheck()
    }
    
    func presentPopupView(from viewController: UIViewController) {
        viewController.view.addSubview(self)
        self.snp.makeConstraints { make in make.edges.equalToSuperview() }
        self.animateForPresent()
    }
    
    func dismissPopupView(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.termsView.transform = CGAffineTransform(translationX: 0, y: 290)
            self.dimView.alpha       = 0
        }) { _ in
            completion?()
            self.removeFromSuperview()
        }
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
        self.dimView.addGestureRecognizer(tapGesture)
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
                guard let self = self else { return }
                self.dismissPopupView { self.delegate?.termsOfServiceViewDidTapComplete(self) }
            })
            .disposed(by: self.disposeBag)
        
        Observable.merge(self.personalTermButton.rx.tap.asObservable(),
                         self.personalTermDescButton.rx.tap.asObservable())
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.delegate?.termsOfServiceViewDidTapPersonalTerm(self)
            }).disposed(by: self.disposeBag)
        
        Observable.merge(self.serviceTermButton.rx.tap.asObservable(),
                         self.serviceTermDescButton.rx.tap.asObservable())
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.delegate?.termsOfServiceViewDidTapServiceTerm(self)
            }).disposed(by: self.disposeBag)
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
