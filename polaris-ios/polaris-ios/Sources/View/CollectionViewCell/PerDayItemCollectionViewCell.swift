//
//  PerDayItemCollectionViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import UIKit

class PerDayItemCollectionViewCell: UICollectionViewCell {
    override var isSelected: Bool { didSet { self.update(by: self.isSelected) } }
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupInit()
    }

    // MARK: - Set Up
    private func setupInit() {
        self.update(by: false)
        self.makeRounded(cornerRadius: 15)
    }
    
    func configure(day: String, dayNumber: Int) {
        self.dayLabel.text       = day
        self.dayNumberLabel.text = "\(dayNumber)"
    }
    
    private func update(by isSelected: Bool) {
        if isSelected {
            self.backgroundColor = type(of: self).selectedBackgroundColor
            self.dayLabel.textColor = type(of: self).selectedTextColor
            self.dayNumberLabel.textColor = type(of: self).selectedTextColor
        } else {
            self.backgroundColor = type(of: self).unselectedBackgroundColor
            self.dayLabel.textColor = type(of: self).unselectedTextColor
            self.dayNumberLabel.textColor = type(of: self).unselectedTextColor
        }
    }
    
    private static let selectedBackgroundColor: UIColor     = .mainSky
    private static let unselectedBackgroundColor: UIColor   = .inactiveSky
    
    private static let selectedTextColor: UIColor           = .white
    private static let unselectedTextColor: UIColor         = .inactiveTextSky
}
