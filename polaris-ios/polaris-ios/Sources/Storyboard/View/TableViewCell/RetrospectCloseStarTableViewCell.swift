//
//  RetrospectCloseStarTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/06.
//

import RxSwift
import RxCocoa
import UIKit

class RetrospectCloseStarTableViewCell: RetrospectReportCell {
    
    override class var cellHeight: CGFloat { 160 + 24 }

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
    }
    
    private func layoutCollectionView() {
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
            collectionViewLayout.itemSize = CGSize(width: 48, height: 84)
            collectionViewLayout.minimumLineSpacing = 20
            collectionViewLayout.minimumInteritemSpacing = 0
            collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 27, bottom: 0, right: 27)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
}

extension RetrospectCloseStarTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: - 서버 데이터 반영 필요
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: RetrospectJourneyItemCell.self, forIndexPath: indexPath)
        
        guard let itemCell = cell else { return UICollectionViewCell() }
        itemCell.configure(journey: .control)
        return itemCell
    }
    
}

extension RetrospectCloseStarTableViewCell: UICollectionViewDelegate {
    
    
}
