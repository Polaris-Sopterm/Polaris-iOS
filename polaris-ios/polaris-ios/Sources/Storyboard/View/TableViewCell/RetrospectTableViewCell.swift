//
//  RetrospectTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/09/04.
//

import RxCocoa
import RxSwift
import UIKit

class RetrospectTableViewCell: MainTableViewCell {
    
    override class var cellHeight: CGFloat { return DeviceInfo.screenHeight }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.navigationHeightConstraint.constant = type(of: self).navigationHeight
        self.setupLabels()
        self.setupCometAnimation()
        self.bindButtons()
        self.observeViewModel()
        
        self.viewModel.requestRetrospectValues()
    }
    
    private func setupLabels() {
        let text: String =
            """
            내가 찾은 별로
            나의 우주가 좀 더 밝아졌어요
            """
        let subRange = text.subRange(of: "나의 우주가 좀 더 밝아졌어요")
        
        let attributeText = NSMutableAttributedString(string: text)
        attributeText.addAttribute(.kern, value: -0.69, range: NSRange(location: 0, length: text.count))
        attributeText.setLineHeight(33, UIFont.systemFont(ofSize: 23), .left)
        attributeText.addAttribute(.font, value: UIFont.systemFont(ofSize: 23, weight: .bold), range: subRange)
        self.titleLabel.attributedText = attributeText
    }
    
    private func setupCometAnimation() {
        (0...2).forEach { _ in self.startCometAnimation() }
    }
    
    private func startCometAnimation() {
        guard let cometType = ShootingComet.allCases.randomElement() else { return }
        
        let yPosition = CGFloat(Int.random(in: 0...400))
        let duration  = Double(Int.random(in: 15...60)) / 10.0
        
        let cometImageView   = UIImageView(image: cometType.starImage)
        cometImageView.frame = CGRect(x: DeviceInfo.screenWidth, y: yPosition, width: cometType.size, height: cometType.size)
        self.contentView.addSubview(cometImageView)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            cometImageView.transform = CGAffineTransform(translationX: -DeviceInfo.screenWidth - 120, y: DeviceInfo.screenWidth + 120)
        }, completion: { [weak self] _ in
            cometImageView.removeFromSuperview()
            self?.startCometAnimation()
        })
    }
    
    private func bindButtons() {
        self.seeReportButton.rx.tap.observeOnMain(onNext: {
            guard let visibleController = UIViewController.getVisibleController() else { return }
            guard let mainVC = visibleController as? MainVC                       else { return }
            
            mainVC.pushRetrospectViewController()
        }).disposed(by: self.disposeBag)
        
        self.shareButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.presentActivityController()
        }).disposed(by: self.disposeBag)
    }
    
    private func observeViewModel() {
        self.viewModel.journeyValueRelay
            .withUnretained(self)
            .observeOnMain(onNext: { owner, valuesModel in
                let sortedValues = owner.viewModel.sortRetrospectValueModel(model: valuesModel)
                
                owner.layoutStarAsRetrospectValues(sortedValues: sortedValues)
            }).disposed(by: self.disposeBag)
    }
    
    private func presentActivityController() {
        guard let visibleController = UIViewController.getVisibleController() else { return }
        guard let starsImage = self.capturedStarContainerImage                else { return }
        
        let activityController = UIActivityViewController(activityItems: [starsImage], applicationActivities: nil)
        visibleController.present(activityController, animated: true, completion: nil)
    }
    
    private func layoutStarAsRetrospectValues(sortedValues: [(String, Int)]) {
        sortedValues.enumerated().forEach { index, value in
            let ranking = index
            let key = value.0
            let collectionCount = value.1
        
            var starSize: CGFloat
            if 0...2 ~= ranking && collectionCount == 0 { starSize = 48 }
            else if 3...5 ~= ranking                    { starSize = 60 }
            else                                        { starSize = 80 }
                
            guard let journey = Journey(rawValue: key) else { return }
            let constraint = self.starConstraint(asJourney: journey)
            constraint.constant = starSize
            self.layoutIfNeeded()
        }
    }
    
    private func starConstraint(asJourney journey: Journey) -> NSLayoutConstraint {
        switch journey {
        case .happiness: return self.happinessStarWidthConstraint
        case .control:   return self.controlStarWidthConstraint
        case .thanks:    return self.thanksStarConstraint
        case .rest:      return self.restStarWidthConstraint
        case .growth:    return self.growthStarConstraint
        case .change:    return self.changeStarWidthConstraint
        case .health:    return self.healthStarConstraint
        case .overcome:  return self.overcomeStarWidthConstraint
        case .challenge: return self.challengeStarConstraint
        }
    }
    
    private var capturedStarContainerImage: UIImage? {
        let contentViewAsImage = self.contentView.asImage()
        let screenScale = UIScreen.main.scale
        let croppedFrame = self.starsContainerView.frame
        let croppedFrameAdjustScale = CGRect(
            x: croppedFrame.origin.x * screenScale,
            y: croppedFrame.origin.y * screenScale,
            width: croppedFrame.size.width * screenScale,
            height: croppedFrame.size.height * screenScale
        )
        return contentViewAsImage?.cropImage(rect: croppedFrameAdjustScale)
    }
    
    private static var navigationHeight: CGFloat {
        return 51 + DeviceInfo.topSafeAreaInset
    }
    
    private let viewModel = RetrospectViewModel()
    private let disposeBag = DisposeBag()

    @IBOutlet private weak var starsContainerView: UIView!
    
    @IBOutlet private weak var changeStarWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var happinessStarWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var overcomeStarWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var controlStarWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var restStarWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var healthStarConstraint: NSLayoutConstraint!
    @IBOutlet private weak var growthStarConstraint: NSLayoutConstraint!
    @IBOutlet private weak var thanksStarConstraint: NSLayoutConstraint!
    @IBOutlet private weak var challengeStarConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var navigationHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var seeReportButton: UIButton!
    
}
