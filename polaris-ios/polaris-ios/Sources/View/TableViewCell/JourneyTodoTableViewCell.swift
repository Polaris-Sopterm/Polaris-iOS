//
//  JourneyTodoTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/05/16.
//

import UIKit

class JourneyTodoTableViewCell: UITableViewCell {
    
    static var cellHeight: CGFloat { return 63 * screenRatio }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private static let screenRatio: CGFloat = DeviceInfo.screenWidth / 375
    
    @IBOutlet private weak var fixImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    
}
