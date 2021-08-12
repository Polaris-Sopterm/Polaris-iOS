//
//  DropdownItemTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/19.
//

import UIKit

class DropdownItemTableViewCell: UITableViewCell {
    
    func configure(by journeyModel: JourneyTitleModel) {
        self.journeyModel = journeyModel
        
        self.menuLabel.text = journeyModel.displayTitle
    }
    
    private var journeyModel: JourneyTitleModel?
    
    @IBOutlet private weak var menuLabel: UILabel!
    
}


