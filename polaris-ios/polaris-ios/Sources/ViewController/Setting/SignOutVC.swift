//
//  SignOutVC.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/28.
//

import RxCocoa
import RxSwift
import UIKit

final class SignOutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLabels()
        self.bindButtons()
        self.observeViewModel()
    }
    
    private func setupLoadingIndicatorView() {
        self.view.addSubview(self.loadingIndicatorView)
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        self.loadingIndicatorView.isHidden = true
        self.loadingIndicatorView.stopAnimating()
    }
    
    private func setupLabels() {
        let title = "정말 탈퇴하시겠어요?"
        let boldRange = title.subRange(of: "탈퇴")
        
        let attributeText = NSMutableAttributedString(string: title)
        attributeText.addAttribute(.font, value: UIFont.systemFont(ofSize: 23, weight: .bold),
                                   range: boldRange)
        self.titleLabel.attributedText = attributeText
    }
    
    private func bindButtons() {
        self.backButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: self.disposeBag)
        
        self.signoutButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.viewModel.requestSignout()
        }).disposed(by: self.disposeBag)
    }
    
    private func observeViewModel() {
        self.viewModel.completeSubject.observeOnMain(onNext: {
            PolarisUserManager.shared.processClearUserInformation()
        }).disposed(by: self.disposeBag)
        
        self.viewModel.loadingSubject.observeOnMain(onNext: { [weak self] loading in
            self?.loadingIndicatorView.isHidden = loading == false
            loading ? self?.loadingIndicatorView.startAnimating() : self?.loadingIndicatorView.stopAnimating()
        }).disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel  = SignoutViewModel()
    
    
    private let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var signoutButton: UIButton!
    
}
