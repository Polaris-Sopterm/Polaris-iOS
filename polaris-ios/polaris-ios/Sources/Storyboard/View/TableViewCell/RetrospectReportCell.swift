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
