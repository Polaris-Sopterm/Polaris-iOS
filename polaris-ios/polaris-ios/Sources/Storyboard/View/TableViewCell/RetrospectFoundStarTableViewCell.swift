//
//  RetrospectFoundStarTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/05.
//

import UIKit

class RetrospectFoundStarTableViewCell: RetrospectReportCell {
    
    static override var cellHeight: CGFloat {
        RetrospectLayoutGuide.foundStarCellHeight
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutCollectionView()
        self.setupCollectionView()
    }
    
    override func configure(presentable: RetrospectReportPresentable) {
        super.configure(presentable: presentable)
        
        guard let foundStarModel = self.presentable as? RetrospectFoundStarModel else { return }
        self.updateTitleLabelAttributeText(asDate: foundStarModel.date)
        self.collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(cell: RetrospectFoundStarItemCell.self)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.allowsSelection = false
        self.collectionView.showsHorizontalScrollIndicator = false
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
    
    private func updateTitleLabelAttributeText(asDate date: PolarisDate) {
        let weekNoDic = [1: "첫째주", 2: "둘째주", 3: "셋째주", 4: "넷째주", 5: "다섯째주"]
        let yearText = "\(date.year)년 "
        let monthText = "\(date.month)월 "
        guard let weekNoText = weekNoDic[date.weekNo] else { return }

        let highlightedText = "찾은 별들이에요."
        let titleText = yearText + monthText + weekNoText + "\n" + highlightedText
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
        guard let foundStarModel = self.presentable as? RetrospectFoundStarModel else { return 0 }
        return foundStarModel.foundStar.foundStarCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: RetrospectFoundStarItemCell.self, forIndexPath: indexPath)
        
        guard let foundStarModel = self.presentable as? RetrospectFoundStarModel else { return UICollectionViewCell() }
        guard let foundStar = foundStarModel.foundStar.foundStarsList[safe: indexPath.row] else { return UICollectionViewCell() }
        guard let itemCell = cell else { return UICollectionViewCell() }
        
        itemCell.configure(journey: foundStar)
        itemCell.layoutAsRow(indexPath.row)
        return itemCell
    }
        
}

extension RetrospectFoundStarTableViewCell: UICollectionViewDelegate {
    
}
