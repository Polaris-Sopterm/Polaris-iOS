//
//  RetrospectFoundStarItemCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/05.
//

import UIKit

class RetrospectFoundStarItemCell: UICollectionViewCell {
    
    static var cellSize: CGSize { CGSize(width: 60, height: 131) }
    
    func configure(journey: Journey) {
        self.journeyNameLabel.text = journey.rawValue
        self.journeyImageView.image = journey.getImage()
    }
    
    func layoutAsRow(_ row: Int) {
        self.topConstraint.constant = row % 2 == 0 ? 0 : 33
        self.layoutIfNeeded()
    }

    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var journeyImageView: UIImageView!
    @IBOutlet private weak var journeyNameLabel: UILabel!
    
}
