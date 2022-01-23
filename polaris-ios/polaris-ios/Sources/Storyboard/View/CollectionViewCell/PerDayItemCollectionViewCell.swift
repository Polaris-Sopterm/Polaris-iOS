//
//  PerDayItemCollectionViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/23.
//

import UIKit

class PerDayItemCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool { didSet { self.update(by: self.isSelected) } }
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.update(by: false)
    }

    func configure(_ date: Date) {
       let weekDay = Calendar.current.component(.weekday, from: date)
        let day    = Calendar.current.component(.day, from: date)
        
        self.dayLabel.text       = Date.WeekDay(rawValue: weekDay)?.korWeekday
        self.dayNumberLabel.text = "\(day)"
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
