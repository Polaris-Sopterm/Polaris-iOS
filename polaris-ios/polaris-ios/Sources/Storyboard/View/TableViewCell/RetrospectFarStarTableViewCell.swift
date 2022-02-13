//
//  RetrospectFarStarTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/06.
//

import UIKit

class RetrospectFarStarTableViewCell: RetrospectReportCell {
    
    override class var cellHeight: CGFloat {
        RetrospectLayoutGuide.farStarCellHeight
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutCollectionView()
        self.setupCollectionView()
    }
    
    override func configure(presentable: RetrospectReportPresentable) {
        super.configure(presentable: presentable)
        self.collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(cell: RetrospectJourneyItemCell.self)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.allowsSelection = false
        self.collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func layoutCollectionView() {
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
            collectionViewLayout.itemSize = RetrospectJourneyItemCell.cellSize
            collectionViewLayout.minimumLineSpacing = 20
            collectionViewLayout.minimumInteritemSpacing = 0
            collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 27, bottom: 0, right: 27)
        }
    }
    
    private var farStarPresentable: RetrospectFarStarsModel? {
        self.presentable as? RetrospectFarStarsModel
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
}

extension RetrospectFarStarTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.farStarPresentable?.farStars.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: RetrospectJourneyItemCell.self, forIndexPath: indexPath)
        let farStars = self.farStarPresentable?.farStars
        
        guard let itemCell = cell else { return UICollectionViewCell() }
        guard let journey = farStars?[safe: indexPath.row] else { return UICollectionViewCell() }
        itemCell.configure(journey: journey)
        return itemCell
    }
    
}

extension RetrospectFarStarTableViewCell: UICollectionViewDelegate {}
