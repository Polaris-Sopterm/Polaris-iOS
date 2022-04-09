//
//  JourneyCollectionView.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/04/09.
//

import UIKit

final class JourneyCollectionView: UICollectionView {
        
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cell(forJourney journey: Journey) -> JourneyCollectionViewCell? {
        guard let journeyIndex = self.journeyList.firstIndex(of: journey)                       else { return nil }
        guard let journeyCell = self.cellForItem(at: IndexPath(item: journeyIndex, section: 0)) else { return nil }
        return journeyCell as? JourneyCollectionViewCell
    }
    
    private func setupProperties() {
        self.registerCell(cell: JourneyCollectionViewCell.self)
        self.backgroundColor = .clear
        self.allowsSelection = false
        self.isScrollEnabled = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.dataSource = self
    }
    
    private let journeyList = Journey.allCases
    
}

extension JourneyCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Journey.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: JourneyCollectionViewCell.self, forIndexPath: indexPath)
        let journey = self.journeyList[safe: indexPath.row]
        
        guard let journeyCell = cell else { return UICollectionViewCell() }
        guard let journey = journey  else { return UICollectionViewCell() }
        
        journeyCell.configure(journey: journey)
        return journeyCell
    }
    
}
