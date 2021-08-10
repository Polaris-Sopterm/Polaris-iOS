//
//  OnboardingCollectionViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/09.
//

import RxCocoa
import RxSwift
import UIKit

protocol OnboardingCollectionViewCellDelegate: AnyObject {
    func onboardingCollectionViewCellDidTapPrevious(_ cell: OnboardingCollectionViewCell)
    func onboardingCollectionViewCellDidTapNext(_ cell: OnboardingCollectionViewCell)
    func onboardingCollectionViewCellDidTapStart(_ cell: OnboardingCollectionViewCell)
}

class OnboardingCollectionViewCell: UICollectionViewCell {

    weak var delegate: OnboardingCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutBottom()
        self.bindButtons()
    }

    func configure(_ level: OnboardingVC.OnboardingLevel) {
        self.titleLabel.text            = level.title
        self.subTitleLabel.text         = level.subTitle
        self.descriptionLabel.text      = level.description
        self.onboardingImageView.image  = level.image
        
        self.previousButton.isHidden = level == .first || level == .last
        self.nextButton.isHidden     = level == .last
        self.startButton.isHidden    = level != .last
    }
    
    func willDisplay() {
        self.titleLabel.alpha              = 0
        self.subTitleLabel.alpha           = 0
        self.descriptionLabel.alpha        = 0
        self.onboardingImageView.alpha     = 0
        self.onboardingImageView.transform = CGAffineTransform(translationX: 0, y: 300)
        
        UIView.animate(withDuration: 1.0) {
            self.titleLabel.alpha              = 1
            self.subTitleLabel.alpha           = 1
            self.descriptionLabel.alpha        = 1
            self.onboardingImageView.alpha     = 1
            self.onboardingImageView.transform = .identity
        }
    }
    
    private func bindButtons() {
        self.previousButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.onboardingCollectionViewCellDidTapPrevious(self)
        }).disposed(by: self.disposeBag)
        
        self.nextButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.onboardingCollectionViewCellDidTapNext(self)
        }).disposed(by: self.disposeBag)
        
        self.startButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.onboardingCollectionViewCellDidTapStart(self)
        }).disposed(by: self.disposeBag)
    }
    
    private func layoutBottom() {
        self.nextLabelBottomConstraint.constant = 37 + DeviceInfo.bottomSafeAreaInset
        self.previousBottomConstraint.constant  = 37 + DeviceInfo.bottomSafeAreaInset
        self.startBottomConstraint.constant     = 37 + DeviceInfo.bottomSafeAreaInset
    }
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var nextLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var previousBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var startBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var onboardingImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    
}
