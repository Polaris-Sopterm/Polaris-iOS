//
//  ConfirmPopupView.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/09/03.
//

import RxSwift
import UIKit

class ConfirmPopupView: UIView {
    
    typealias Handler = () -> Void
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
    }
    
    func configure(title: String? = nil, subTitle: String? = nil, confirmHandler: Handler? = nil) {
        self.titleLabel.text    = title
        self.subTitleLabel.text = subTitle
        self.confirmHandler     = confirmHandler
    }
    
    func show(in view: UIView) {
        view.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.showCrossDissolve(duration: 0.2)
    }
    
    func hide(completion: Handler?) {
        self.hideCrossDissolve { [weak self] in
            self?.removeFromSuperview()
        }
    }
    
    private func bindButtons() {
        self.confirmButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.hide { self?.confirmHandler?() }
        }).disposed(by: self.disposeBag)
    }

    private var confirmHandler: Handler?
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    
}
