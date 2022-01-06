//
//  RetrospectReportCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/05.
//

import UIKit

protocol RetrospectReportPresentable {}

class RetrospectReportCell: UITableViewCell {
    
    class var cellHeight: CGFloat { return 0 }
    
    func configure(presentable: RetrospectReportPresentable) {}
    
}
