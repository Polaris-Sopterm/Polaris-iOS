//
//  RetrospectFarStarTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/06.
//

import UIKit

class RetrospectFarStarTableViewCell: RetrospectReportCell {
    
    override class var cellHeight: CGFloat { 8 + 160 }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutCollectionView()
        self.setupCollectionView()
    }
    
    override func configure(presentable: RetrospectReportPresentable) {
        super.configure(presentable: presentable)
        
        // TODO: - 서버 데이터 반영 필요
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(cell: RetrospectJourneyItemCell.self)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func layoutCollectionView() {
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
            collectionViewLayout.itemSize = RetrospectJourneyItemCell.cellSize
            collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 27, bottom: 0, right: 27)
            collectionViewLayout.minimumLineSpacing = 20
            collectionViewLayout.minimumInteritemSpacing = 0
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
}

extension RetrospectFarStarTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: RetrospectJourneyItemCell.self, forIndexPath: indexPath)
        
        guard let itemCell = cell else { return UICollectionViewCell() }
        itemCell.configure(journey: .rest)
        return itemCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
}


extension RetrospectFarStarTableViewCell: UICollectionViewDelegate {
    
}
