//
//  SelectStarItemCollectionViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import UIKit

class SelectStarItemCollectionViewCell: UICollectionViewCell {
        
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .field
        self.makeRounded(cornerRadius: 20)
    }

    // MARK: - Set Up
    func configure(by journey: Journey, _ isSelected: Bool = false) {
        self.starImageView.image = journey.getImage()
        self.starLabel.text      = journey.rawValue
        self.update(by: isSelected)
    }
    
    private func update(by isSelected: Bool) {
        if isSelected {
            self.backgroundColor        = type(of: self).selectedBackgroundColor
            self.starLabel.textColor    = type(of: self).selectedTextColor
            self.layer.borderWidth      = 1
            self.layer.borderColor      = type(of: self).selectedBorderColor.cgColor
        } else {
            self.backgroundColor        = type(of: self).unselectedBackgroundColor
            self.starLabel.textColor    = type(of: self).unselectedTextColor
            self.layer.borderWidth      = 0
            self.layer.borderColor      = type(of: self).unselectedBorderColor.cgColor
        }
    }
    
    private static let selectedBackgroundColor: UIColor     = .inactiveSky
    private static let unselectedBackgroundColor: UIColor   = .field
    
    private static let selectedBorderColor: UIColor         = .mainSky
    private static let unselectedBorderColor: UIColor       = .clear
    
    private static let selectedTextColor: UIColor           = .textSky
    private static let unselectedTextColor: UIColor         = .inactiveText
    
    @IBOutlet private weak var starImageView: UIImageView!
    @IBOutlet private weak var starLabel: UILabel!
    
}
