//
//  NickChangeVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/08/23.
//

import UIKit
import RxSwift
import RxCocoa

final class NickChangeVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationProperty()
        self.setUIs()
        self.observeViewModel()
    }
    
    private func setUIs() {
        self.titleLabel.setPartialBold(originalText: "별명을\n변경해주세요", boldText: "별명", fontSize: 23.0, boldFontSize: 23.0)
        self.titleLabel.textColor = .maintext
        self.nickTextField.makeRounded(cornerRadius: 16.0)
        self.nickTextField.setBorder(borderColor: .inactiveText, borderWidth: 1.0)
        self.nickTextField.font = UIFont.systemFont(ofSize: 16.0)
        self.nickTextField.addLeftPadding(left: 26.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeButtonAction(_ sender: Any) {
        guard let nickname = self.nickTextField.text else { return }
        self.viewModel.requestChangeNickname(nickname: nickname)
    }
    
    private func setupNavigationProperty() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    private func observeViewModel() {
        self.viewModel.loadingSubject
            .bind(to: self.indicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        self.viewModel.loadingSubject
            .map { !$0 }
            .bind(to: self.indicatorContainerView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        self.viewModel.completeSubejct
            .withUnretained(self)
            .observeOnMain(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    private let viewModel = NickChangeViewModel()
    
}
