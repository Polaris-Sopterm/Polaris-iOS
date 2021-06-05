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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
    }
    
    func presentPopupView(from viewController: UIViewController) {
        viewController.view.addSubview(self)
        self.snp.makeConstraints { make in make.edges.equalToSuperview() }
        self.animateForPresent()
    }
    
    func dismissPopupView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.termsView.transform = CGAffineTransform(translationX: 0, y: 290)
            self.dimView.alpha       = 0
        }) { _ in
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
    
    private func bindButtons() {
        self.closeButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.dismissPopupView()
            })
            .disposed(by: self.disposeBag)
        
    }
    
    private var disposeBag = DisposeBag()

    @IBOutlet private weak var dimView: UIView!
    @IBOutlet private weak var termsView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var personalTermsCheckButton: UIButton!
    @IBOutlet private weak var serviceTermsCheckButton: UIButton!
    
}
