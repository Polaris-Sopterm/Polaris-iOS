//
//  PolarisStoryViewController.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/09/04.
//

import RxCocoa
import RxSwift
import UIKit

class PolarisStoryVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLabels()
        self.bindButtons()
    }
    
    private func setupLabels() {
        let text =
        """
        우리는 일상 속에서 수많은 계획을 세웁니다.
        그렇다면 그 계획이 어떤 ‘가치'를
        달성하기 위함인지 고민해본 적이 있나요?

        폴라리스와 일주일의 항해를 함께 해봐요!
        여러분이 세운 그 목표의 지향점과
        걸어온 발자취를 되돌아보다보면
        어느새 여러분의 별은 환하게 빛나고 있을거에요.
        """
        
        let attributeText = NSMutableAttributedString(string: text)
        attributeText.setLineHeight(28, UIFont.systemFont(ofSize: 15, weight: .regular), .center)
        self.titleLabel.attributedText = attributeText
    }
    
    private func bindButtons() {
        self.backButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: self.disposeBag)
        
        Observable.merge(self.makeButton.rx.tap.asObservable(), self.makeTextButton.rx.tap.asObservable())
            .observeOnMain(onNext: { [weak self] in
                guard let self = self else { return }
                
                let viewController = PolarisMakersVC.instantiateFromStoryboard(StoryboardName.setting)
                
                guard let makersViewController = viewController else { return }
                self.navigationController?.pushViewController(makersViewController, animated: true)
            }).disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()

    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var makeButton: UIButton!
    @IBOutlet private weak var makeTextButton: UIButton!
    
}
