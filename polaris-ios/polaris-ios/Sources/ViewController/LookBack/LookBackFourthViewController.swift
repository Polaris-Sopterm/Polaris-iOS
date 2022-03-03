//
//  LookBackFourthViewController.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/01/02.
//

import UIKit
import Combine

struct LookBackEmotion: Codable, Hashable, Equatable  {
    var emotion: String
    var emotionImageName: String
    var isSelected: Bool
}

class LookBackFourthViewController: UIViewController, LookBackViewModelProtocol {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var emotionCollectionView: UICollectionView!
    
    @IBOutlet weak var topYConstraint: NSLayoutConstraint!
    @IBOutlet weak var subLabelYConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionVIewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButtonYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: UIButton!
    private let deviceHeightRatio = DeviceInfo.screenHeight/812.0
    private let deviceWidthRatio = DeviceInfo.screenWidth/375.0
    private var deviceSize: DeviceHeightSizeType = .normal
    
    private var viewModel = LookBackViewModel()
    private weak var pageDelegate: LookBackPageDelegate?
    
    private var emotionSubscription: AnyCancellable?
    private var nextButtonSubscription: AnyCancellable?
    private var dataSource: DataSource?
    

    typealias DataSource = UICollectionViewDiffableDataSource<Section, LookBackEmotion>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, LookBackEmotion>

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIs()
        self.setUpDataSource()
        self.viewModel.publishFourthEmotionInfo()
        // Do any additional setup after loading the view.
    }
    
    private func setUIs() {
        if DeviceInfo.screenHeight < 700 {
            self.deviceSize = .small
        }

        self.titleLabel.textColor = .maintext
        self.titleLabel.setPartialBold(originalText: "지난 한 주를 생각하면\n어떤 감정이 느껴지나요?", boldText: "어떤 감정", fontSize: 22, boldFontSize: 22)
        self.subTitleLabel.textColor = .maintext

        self.emotionCollectionView.registerCell(cell: LookBackFourthCollectionViewCell.self)
        self.emotionCollectionView.delegate = self
        self.emotionCollectionView.registerCell(cell: LookBackSecondCollectionViewCell.self)
        
        self.nextButton.setTitle("", for: .normal)
        self.nextButton.setImage(UIImage(named: "btnNextDisabled"), for: .normal)
        self.nextButton.isEnabled = false
        
        self.topYConstraint.constant *= deviceHeightRatio
        self.subLabelYConstraint.constant *= deviceHeightRatio
        self.nextButtonYConstraint.constant *= deviceHeightRatio
    
        switch self.deviceSize {
        case .normal:
            self.collectionViewYConstraint.constant *= deviceHeightRatio
            self.collectionVIewHeightConstraint.constant *= deviceHeightRatio
        case .small:
            self.collectionViewYConstraint.constant = 32
            self.collectionVIewHeightConstraint.constant = 400
        }
    }
    
    private func setUpDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.emotionCollectionView, cellProvider: { [weak self] (collectionView, indexPath, emotion) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LookBackFourthCollectionViewCell", for: indexPath) as! LookBackFourthCollectionViewCell
            cell.setEmotion(emotion: emotion, index: indexPath.item)
            if let viewModel = self?.viewModel {
                cell.setViewModel(viewModel: viewModel)
            }
            return cell
        })
        self.emotionSubscription = viewModel.$fourthvcEmotions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] emotions in
                guard let self = self else { return }
                self.updateEmotions(emotions: emotions)
            })
        self.nextButtonSubscription = viewModel.$fourthvcNextButtonAble
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                guard let self = self else { return }
                if value {
                    self.nextButton.setImage(UIImage(named: "btnNextEnabled"), for: .normal)
                    self.nextButton.isEnabled = true
                }
                else {
                    self.nextButton.setImage(UIImage(named: "btnNextDisabled"), for: .normal)
                    self.nextButton.isEnabled = false
                }
            })
    }
    
    private func updateEmotions(emotions: [LookBackEmotion]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(emotions)
        guard let dataSource = self.dataSource else {
            return
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setViewModel(viewModel: LookBackViewModel) {
        self.viewModel = viewModel
    }
    
    func setPageDelegate(delegate: LookBackPageDelegate) {
        self.pageDelegate = delegate
    }
    

    @IBAction func nextButtonAction(_ sender: Any) {
        self.pageDelegate?.toNextPage()
    }
    
}


extension LookBackFourthViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 101 * deviceWidthRatio, height: 101 * deviceWidthRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
    }
}
