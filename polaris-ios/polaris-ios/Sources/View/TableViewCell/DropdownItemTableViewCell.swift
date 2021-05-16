//
//  DropdownItemTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/19.
//

import UIKit

class DropdownItemTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
    }
    
    func configure(by menu: String) {
        self.menuLabel.text = menu
    }
    
    @IBOutlet private weak var menuLabel: UILabel!
    
}


