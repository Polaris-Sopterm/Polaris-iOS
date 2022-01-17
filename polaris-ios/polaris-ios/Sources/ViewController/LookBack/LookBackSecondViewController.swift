//
//  LookBackSecondViewController.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/12/26.
//

import UIKit
import Combine


class LookBackSecondViewController: UIViewController, LookBackViewModelProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var starCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var topYConstraint: NSLayoutConstraint!
    @IBOutlet weak var subLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButtonYConstraint: NSLayoutConstraint!
    
    private let deviceHeightRatio = DeviceInfo.screenHeight/812.0
    private var viewModel = LookBackViewModel()
    private var subscriptions: [AnyCancellable] = []
    private var starSubsciption: AnyCancellable?
    private var nextButtonSubscription: AnyCancellable?
    private var titleLabelSubscription: AnyCancellable?
    private var dataSource: DataSource?
    
    private weak var pageDelegate: LookBackPageDelegate?


    typealias DataSource = UICollectionViewDiffableDataSource<Section, LookBackStar>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, LookBackStar>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIs()
        self.setUpDataSource()
        self.starCollectionView.delegate = self
        self.viewModel.publishSecondStarInfos()
    }
    
    private func setUIs() {
        self.titleLabel.textColor = .maintext
        self.titleLabel.setPartialBold(originalText: "당신 마음에\n가장 가까이 닿은 별은 어떤 별인가요? ", boldText: "가장 가까이 닿은 별", fontSize: 22, boldFontSize: 22)
        self.subTitleLabel.textColor = .maintext

        self.starCollectionView.registerCell(cell: LookBackSecondCollectionViewCell.self)
        
        self.nextButton.setTitle("", for: .normal)
        self.nextButton.setImage(UIImage(named: "btnNextDisabled"), for: .normal)
        self.nextButton.isEnabled = false
        
        self.topYConstraint.constant *= deviceHeightRatio
        self.subLabelConstraint.constant *= deviceHeightRatio
        self.collectionViewYConstraint.constant *= deviceHeightRatio
        self.collectionViewHeightConstraint.constant *= deviceHeightRatio
        self.nextButtonYConstraint.constant *= deviceHeightRatio
    }
    

    private func setUpDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: starCollectionView, cellProvider: { [weak self] (collectionView, indexPath, star) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LookBackSecondCollectionViewCell", for: indexPath) as! LookBackSecondCollectionViewCell
            cell.setStar(star: star, index: indexPath.item)
            if let viewModel = self?.viewModel {
                cell.setViewModel(viewModel: viewModel)
            }
            cell.setViewControllerCase(input: .second)
            return cell
        })
        self.starSubsciption = viewModel.$secondvcStars
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] stars in
                guard let self = self else { return }
                self.updateStars(stars: stars)
            })
        self.nextButtonSubscription = viewModel.$secondvcNextButtonAble
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
        self.titleLabelSubscription = self.viewModel.$secondvcTitle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                guard let self = self else { return }
                if value.text.contains("않은") {
                    self.subTitleLabel.text = "한 주 동안 아쉬웠던 별을 선택해보세요."
                }
                else {
                    self.subTitleLabel.text = "한 주 동안 좋았던 별을 선택해보세요."
                }
                self.nextButton.setImage(UIImage(named: "btnNextDisabled"), for: .normal)
                self.nextButton.isEnabled = false
                UIView.transition(with: self.titleLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.titleLabel.setPartialBold(originalText: value.text, boldText: value.highlightedText, fontSize: 22, boldFontSize: 22)
                }, completion: nil)
                
            })
        
    }
    
    private func updateStars(stars: [LookBackStar]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(stars)
        guard let dataSource = self.dataSource else {
            return
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setViewModel(viewModel: LookBackViewModel) {
        self.viewModel = viewModel
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        self.viewModel.secondvcNextButtonTapped()
    }
    
    func setPageDelegate(delegate: LookBackPageDelegate) {
        self.pageDelegate = delegate
    }
}

extension LookBackSecondViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 101, height: 101 * deviceHeightRatio)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 * deviceHeightRatio
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
    }
}
