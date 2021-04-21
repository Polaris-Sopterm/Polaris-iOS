//
//  AddTodoDayTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/21.
//

import UIKit

class AddTodoDayTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat {
        let verticalInset: CGFloat  = 10
        let labelHeight: CGFloat    = 17
        let spacing: CGFloat        = 15
        
        return 100
    }
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Set Up
    private func layoutColletionView() {
        
    }
    
    
    
    private static let horizontalInset: CGFloat     = 23
    private static let verticalInset: CGFloat       = 10
    private static let screenRatio: CGFloat         = DeviceInfo.screenWidth / 375
    private static let dayCellWidth: CGFloat        = 45 * screenRatio
    private static let dayCellHeight: CGFloat       = 66 * screenRatio
}
