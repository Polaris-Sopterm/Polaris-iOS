//
//  PolarisPopupView.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/21.
//

import RxCocoa
import RxSwift
import UIKit

class PolarisPopupView: UIView {
    
    typealias Handler = (() -> Void)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
    }
    
    func configure(title: String, subTitle: String? = nil,
                   cancelTitle: String = "취소", confirmTitle: String = "확인",
                   confirmHandler: Handler? = nil, cancelHandler: Handler? = nil) {
        self.titleLabel.text    = title
        self.subTitleLabel.text = subTitle
        self.confirmButton.setTitle(confirmTitle, for: .normal)
        self.cancelButton.setTitle(cancelTitle, for: .normal)
        
        self.confirmHandler = confirmHandler
        self.cancelHandler  = cancelHandler
    }
    
    func show(in view: UIView) {
        view.addSubview(self)
        self.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }
    
    private func animateForShow() {
        self.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    private func animateForHide(completion: Handler? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
    
    private func bindButtons() {
        self.confirmButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.animateForHide(completion: self?.confirmHandler)
        }).disposed(by: self.disposeBag)
        
        self.cancelButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.animateForHide(completion: self?.cancelHandler)
        }).disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    private var cancelHandler: Handler?
    private var confirmHandler: Handler?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var confirmButton: UIButton!
    
}
