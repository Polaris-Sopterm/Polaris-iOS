//
//  RetrospectReportVC.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/09/06.
//

import RxCocoa
import RxSwift
import UIKit

class RetrospectReportVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topConstraint.constant = DeviceInfo.topSafeAreaInset
    }
    
    private func bindButtons() {
        self.backButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    
}
