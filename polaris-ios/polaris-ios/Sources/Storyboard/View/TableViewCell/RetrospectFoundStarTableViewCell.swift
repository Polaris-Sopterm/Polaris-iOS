//
//  RetrospectFoundStarTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/05.
//

import UIKit

class RetrospectFoundStarTableViewCell: RetrospectReportCell {
    
    static override var cellHeight: CGFloat { return 217 }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutCollectionView()
        self.setupCollectionView()
        
        // FIXME: - 제거 필요 테스트용
        self.updateTitleLabelAttributeText()
    }
    
    override func configure(presentable: RetrospectReportPresentable) {
        super.configure(presentable: presentable)
        // TODO: - 데이터 반영 필요
        self.updateTitleLabelAttributeText()
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(cell: RetrospectFoundStarItemCell.self)
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    private func layoutCollectionView() {
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
            collectionViewLayout.itemSize = RetrospectFoundStarItemCell.cellSize
            collectionViewLayout.minimumLineSpacing = 24
            collectionViewLayout.minimumInteritemSpacing = 0
            collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 31)
        }
    }
    
    private func updateTitleLabelAttributeText() {
        // TODO: - 날짜 값 들어오면 반영 필요
        let dayText = "4월 첫째주"
        let highlightedText = "찾은 별들이에요."
        let titleText = dayText + "\n" + highlightedText
        let attributeText = NSMutableAttributedString(string: titleText,
                                                      attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .regular),
                                                                   .foregroundColor: UIColor.white])
        
        let highlightedRange = (titleText as NSString).range(of: highlightedText)
        attributeText.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: highlightedRange)
        self.titleLabel.attributedText = attributeText
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
}

extension RetrospectFoundStarTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: - 데이터 관리 필요
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: RetrospectFoundStarItemCell.self, forIndexPath: indexPath)
        
        guard let itemCell = cell else { return UICollectionViewCell() }
        itemCell.configure(journey: .challenge)
        itemCell.layoutAsRow(indexPath.row)
        return itemCell
    }
        
}

extension RetrospectFoundStarTableViewCell: UICollectionViewDelegate {
    
}
