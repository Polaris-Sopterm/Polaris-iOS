//
//  RetrospectTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/09/04.
//

import SnapKit
import RxCocoa
import RxSwift
import UIKit

class RetrospectTableViewCell: MainTableViewCell {
    
    override class var cellHeight: CGFloat {
        DeviceInfo.screenHeight
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.navigationHeightConstraint.constant = type(of: self).navigationHeight
        self.setupCollectionView()
        self.addObserver()
        self.addCometAnimation()
        self.bindButtons()
        self.observeViewModel()
        
        self.viewModel.occur(viewEvent: .viewDidLoad)
    }
    
    private func setupCollectionView() {
        self.contentView.addSubview(self.journeyCollectionView)
        self.journeyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabelContainerView.snp.bottom).offset(50)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LayoutGuide.collectionViewHeight)
        }
    }
    
    private func addObserver() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.didUpdateTodo(_:)), name: .didUpdateTodo, object: nil)
    }
    
    @objc private func didUpdateTodo(_ notification: Notification) {
        guard let sceneIdentifier = notification.object as? String else { return }
        self.viewModel.occur(viewEvent: .notifyUpdateTodo(scene: sceneIdentifier))
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
                
                owner.updateJourneyStarUI(asSortedValues: sortedValues)
            }).disposed(by: self.disposeBag)
        
        Observable.zip(self.viewModel.isExistLastWeekRetrospectRelay.asObservable(), self.viewModel.journeyValueRelay)
            .withUnretained(self)
            .subscribe(onNext: { (owner: RetrospectTableViewCell, tuple: (isExistLastWeekRetrospect: Bool,
                                                                          journeyValues: RetrospectValueListModel)) in
                let isArchieve = tuple.isExistLastWeekRetrospect || tuple.journeyValues.isAchieveJourneyAtLeastOne
                owner.updateTitleLabelAsAchieveJourney(isAchieve: isArchieve)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func presentActivityController() {
        guard let visibleController = UIViewController.getVisibleController() else { return }
        guard let starsImage = self.capturedStarContainerImage                else { return }
        
        let activityController = UIActivityViewController(activityItems: [starsImage], applicationActivities: nil)
        visibleController.present(activityController, animated: true, completion: nil)
    }
    
    private func updateJourneyStarUI(asSortedValues sortedValues: [(String, Int)]) {
        sortedValues.enumerated().forEach { index, value in
            let ranking = index
            let key = value.0
            let collectionCount = value.1

            var starSize: CGFloat
            var starLevel: Int
            if 0...2 ~= ranking || collectionCount == 0 {
                starLevel = 1
                starSize = 48
            } else if 3...5 ~= ranking {
                starLevel = 3
                starSize = 60
            } else {
                starLevel = 4
                starSize = 80
            }
            
            guard let journey = Journey(rawValue: key)                                   else { return }
            guard let journeyCell = self.journeyCollectionView.cell(forJourney: journey) else { return }
            journeyCell.updateJourneyImage(size: starSize, journeyLevel: starLevel)
        }
    }
    
    private func updateTitleLabelAsAchieveJourney(isAchieve: Bool) {
        let archieveText =
            """
            내가 찾은 별로
            나의 우주가 좀 더 밝아졌어요
            """
        
        let unArchieveText =
            """
            별을 찾아
            나의 우주를 밝혀봐요
            """
        
        let text: String = isAchieve ? archieveText : unArchieveText
        let subRange = isAchieve ?
        text.subRange(of: "나의 우주가 좀 더 밝아졌어요") : text.subRange(of: "나의 우주를 밝혀봐요")
        
        let attributeText = NSMutableAttributedString(string: text)
        attributeText.addAttribute(.kern, value: -0.69, range: NSRange(location: 0, length: text.count))
        attributeText.setLineHeight(33, UIFont.systemFont(ofSize: 23), .left)
        attributeText.addAttribute(.font, value: UIFont.systemFont(ofSize: 23, weight: .bold), range: subRange)
        self.titleLabel.attributedText = attributeText
    }
    
    private var capturedStarContainerImage: UIImage? {
        let contentViewAsImage = self.contentView.asImage()
        let screenScale = UIScreen.main.scale
        
        let labelContainerFrame = self.titleLabelContainerView.frame
        let collectionViewHeight = LayoutGuide.collectionViewHeight
        
        let spacing: CGFloat = 50
        let croppedFrame = CGRect(
            x: labelContainerFrame.origin.x,
            y: labelContainerFrame.origin.y,
            width: DeviceInfo.screenWidth,
            height: labelContainerFrame.height + spacing + collectionViewHeight
        )

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

    private let journeyCollectionView: JourneyCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = LayoutGuide.cellSize
        layout.sectionInset = LayoutGuide.sectionInset
        layout.minimumLineSpacing = LayoutGuide.minimumLineSpacing
        layout.minimumInteritemSpacing = LayoutGuide.minimumInteritemSpacing
        return JourneyCollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    @IBOutlet private weak var titleLabelContainerView: UIView!
    
    @IBOutlet private weak var navigationHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var seeReportButton: UIButton!
    
}

extension RetrospectTableViewCell {
    
    struct LayoutGuide {
        
        static var collectionViewHeight: CGFloat {
            let verticalItemCount: CGFloat = 3
            let cellHeight = self.cellSize.height
            let totalCellHeight = cellHeight * verticalItemCount
            let totalLineSpaing = self.minimumLineSpacing * (verticalItemCount - 1)
            return totalCellHeight + totalLineSpaing
        }
        
        static var cellSize: CGSize {
            let lineItemCount: CGFloat = 3
            let collectionViewWidth = DeviceInfo.screenWidth - self.sectionInset.left - self.sectionInset.right
            let totalItemWidth = collectionViewWidth - ((lineItemCount - 1) * self.minimumInteritemSpacing)
            let itemWidth = totalItemWidth / lineItemCount
            return CGSize(width: itemWidth, height: itemWidth)
        }
        
        static let sectionInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
        static let minimumLineSpacing: CGFloat = 10
        static let minimumInteritemSpacing: CGFloat = 8
        
    }
    
}
