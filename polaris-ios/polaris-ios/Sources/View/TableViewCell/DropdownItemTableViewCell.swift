//
//  DropdownItemTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/19.
//

import UIKit

class DropdownItemTableViewCell: UITableViewCell {
    @IBOutlet weak var menuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
    }
    
    func configure(by menu: String) {
        self.menuLabel.text = menu
    }
}


