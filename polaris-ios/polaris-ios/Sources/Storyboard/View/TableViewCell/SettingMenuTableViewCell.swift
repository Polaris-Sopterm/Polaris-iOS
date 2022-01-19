//
//  SettingMenuTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/17.
//

import UIKit

class SettingMenuTableViewCell: UITableViewCell {

    func configure(_ menuTitle: String) {
        self.menuTitleLabel.text = menuTitle
    }
    
    @IBOutlet private weak var menuTitleLabel: UILabel!
    
}
