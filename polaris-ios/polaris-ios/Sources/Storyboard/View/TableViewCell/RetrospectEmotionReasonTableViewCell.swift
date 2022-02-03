//
//  RetrospectEmotionReasonTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/08.
//

import UIKit

class RetrospectEmotionReasonTableViewCell: RetrospectReportCell {
    
    override class var cellHeight: CGFloat {
        RetrospectLayoutGuide.emotionReasonCellHeight
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
    
    private func layoutCollectionView() {
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .vertical
            collectionViewLayout.sectionInset = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
            collectionViewLayout.minimumLineSpacing = 18
            collectionViewLayout.minimumInteritemSpacing = 0
            
            let cellWidth = DeviceInfo.screenWidth - (23 * 2) - (16 * 2)
            collectionViewLayout.estimatedItemSize = CGSize(width: cellWidth, height: 25)
            collectionViewLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(cell: RetrospectEmotionReasonItemCell.self)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.allowsSelection = false
    }
    
    private var emotionReasonPresentable: RetrospectEmoticonReasonModel? {
        self.presentable as? RetrospectEmoticonReasonModel
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
}

extension RetrospectEmotionReasonTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emotionReasonPresentable?.reasons.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: RetrospectEmotionReasonItemCell.self, forIndexPath: indexPath)
        let reasons = self.emotionReasonPresentable?.reasons
        
        guard let itemCell = cell else { return UICollectionViewCell() }
        guard let reason = reasons?[safe: indexPath.row] else { return UICollectionViewCell() }
        
        itemCell.configure(reasonText: reason)
        return itemCell
    }
    
}

extension RetrospectEmotionReasonTableViewCell: UICollectionViewDelegate {}
