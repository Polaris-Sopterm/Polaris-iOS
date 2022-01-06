//
//  RetrospectCloseStarItemCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/06.
//

import UIKit

class RetrospectJourneyItemCell: UICollectionViewCell {

    static var cellSize: CGSize { CGSize(width: 48, height: 84) }
    
    func configure(journey: Journey) {
        self.journeyNameLabel.text = journey.rawValue
        self.journeyImageView.image = journey.getImage()
    }

    @IBOutlet private weak var journeyImageView: UIImageView!
    @IBOutlet private weak var journeyNameLabel: UILabel!
    
}
