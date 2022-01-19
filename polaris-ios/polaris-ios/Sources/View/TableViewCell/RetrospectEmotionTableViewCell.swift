//
//  RetrospectEmotionTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/08.
//

import RxCocoa
import RxSwift
import UIKit

class RetrospectEmotionTableViewCell: RetrospectReportCell {
    
    override class var cellHeight: CGFloat { 16 + 160 }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutCollectionView()
        self.setupCollectionView()
    }
    
    override func configure(presentable: RetrospectReportPresentable) {
        super.configure(presentable: presentable)
        // TODO: - 서버 데이터 반영
    }
    
    private func layoutCollectionView() {
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
            collectionViewLayout.itemSize = RetrospectEmotionItemCell.cellSize
            collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
            collectionViewLayout.minimumLineSpacing = 8
            collectionViewLayout.minimumInteritemSpacing = 0
        }
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(cell: RetrospectEmotionItemCell.self)
        self.collectionView.allowsSelection = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    
}

extension RetrospectEmotionTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: - 서버 데이터 반영 필요
        return 4
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: RetrospectEmotionItemCell.self, forIndexPath: indexPath)
        
        guard let itemCell = cell else { return UICollectionViewCell() }
        itemCell.configure(emotion: .easy)
        return itemCell
    }
    
}

extension RetrospectEmotionTableViewCell: UICollectionViewDelegate {
    
}
