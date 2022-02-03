//
//  RetrospectReportCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/05.
//

import UIKit

protocol RetrospectReportPresentable {}

class RetrospectReportCell: UITableViewCell {
    
    var presentable: RetrospectReportPresentable?
    
    class var cellHeight: CGFloat { return 0 }
    
    func configure(presentable: RetrospectReportPresentable) {
        self.presentable = presentable
    }
    
}

struct RetrospectLayoutGuide {
    static let foundStarCellHeight: CGFloat = 217
    static let closeStarCellHeight: CGFloat = 160 + 24
    static let farStarCellHeight: CGFloat = 8 + 160
    static let emotionCellHeight: CGFloat = 16 + 160
    static let emotionReasonCellHeight: CGFloat = 30 + 392
}
