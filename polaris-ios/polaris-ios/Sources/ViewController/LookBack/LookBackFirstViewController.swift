//
//  LookBackFirstViewController.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/12/26.
//

import UIKit
import Combine

struct LookBackStar: Codable, Hashable {
    var starName: String
    var starImageName: String
    var selected: Bool
}

enum Section: Hashable {
    case main
}

class LookBackFirstViewController: UIViewController, LookBackViewModelProtocol {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var starCollectionView: UICollectionView!
    @IBOutlet weak var lookbackButton: UIButton!
        
    @IBOutlet weak var topYConstraint: NSLayoutConstraint!
    @IBOutlet weak var subLabelYConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonYConstraint: NSLayoutConstraint!
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, LookBackStar>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, LookBackStar>
    
    private var viewModel = LookBackViewModel()
    private var subscriptions: [AnyCancellable] = []
    private var starSubsciption: AnyCancellable?
    private var dataSource: DataSource?
    var pageDelegate: LookBackPageDelegate?
    
    private let deviceHeightRatio = DeviceInfo.screenHeight/812.0
    private let deviceWidthRatio = DeviceInfo.screenWidth/375.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIs()
        self.setUpDataSource()
        self.starCollectionView.delegate = self
        self.viewModel.publishFirstStarInfos()
        // Do any additional setup after loading the view.
    }
    
    private func setupUIs() {
        self.titleLabel.textColor = .maintext
        self.subtitleLabel.textColor = .maintext
        self.titleLabel.setPartialBold(originalText: "당신이 한 주 동안 찾은 별이에요.", boldText: "한 주 동안 찾은 별", fontSize: 22, boldFontSize: 22)
        self.starCollectionView.registerCell(cell: LookBackFirstStarCollectionViewCell.self)
        self.lookbackButton.setTitle("", for: .normal)
        self.lookbackButton.setImage(UIImage(named: "btnLookbackStart"), for: .normal)
        self.topYConstraint.constant *= deviceHeightRatio
        self.subLabelYConstraint.constant *= deviceHeightRatio
        self.collectionViewYConstraint.constant *= deviceHeightRatio
        self.collectionViewHeightConstraint.constant *= deviceHeightRatio
        self.buttonYConstraint.constant *= deviceHeightRatio
    }
    
    private func setUpDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: starCollectionView, cellProvider: { (collectionView, indexPath, star) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LookBackFirstStarCollectionViewCell", for: indexPath) as! LookBackFirstStarCollectionViewCell
            cell.setStar(imageName: star.starImageName, starName: star.starName)
            return cell
        })
        self.starSubsciption = viewModel.$firstvcStars
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { stars in
                self.updateStars(stars: stars)
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
        self.pageDelegate?.toNextPage()
    }
    
    func setPageDelegate(delegate: LookBackPageDelegate) {
        self.pageDelegate = delegate
    }
    
}


extension LookBackFirstViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 67 * deviceWidthRatio, height: 97 * deviceHeightRatio)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24 * deviceHeightRatio
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 39 * deviceWidthRatio
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 46 * deviceWidthRatio, bottom: 0, right: 48 * deviceWidthRatio)
    }
}


