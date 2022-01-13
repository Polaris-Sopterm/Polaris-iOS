//
//  LookBackFourthViewController.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/01/02.
//

import UIKit
import Combine

struct LookBackEmotion: Codable, Hashable  {
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
    let deviceHeightRatio = DeviceInfo.screenHeight/812.0
    
    private var viewModel = LookBackViewModel()
    private var pageDelegate: LookBackPageDelegate?
    
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
        self.collectionViewYConstraint.constant *= deviceHeightRatio
        self.collectionVIewHeightConstraint.constant *= deviceHeightRatio
        self.nextButtonYConstraint.constant *= deviceHeightRatio
    }
    
    private func setUpDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.emotionCollectionView, cellProvider: { (collectionView, indexPath, emotion) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LookBackFourthCollectionViewCell", for: indexPath) as! LookBackFourthCollectionViewCell
            cell.setEmotion(emotion: emotion, index: indexPath.item)
            cell.setViewModel(viewModel: self.viewModel)
            return cell
        })
        self.emotionSubscription = viewModel.$fourthvcEmotions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { emotions in
                self.updateEmotions(emotions: emotions)
            })
        self.nextButtonSubscription = viewModel.$fourthvcNextButtonAble
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { value in
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
        return CGSize(width: 101, height: 101 * deviceHeightRatio)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8 * deviceHeightRatio
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
    }
}
