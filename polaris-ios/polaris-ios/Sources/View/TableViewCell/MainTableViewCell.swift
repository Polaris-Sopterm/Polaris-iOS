//
//  MainTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/17.
//

import UIKit

enum MainSceneCellType: Int, CaseIterable {
    case main = 0, todoByDay
    
    var cellType: MainTableViewCell.Type {
        switch self {
        case .main:      return MainSceneTableViewCell.self
        case .todoByDay: return TodoTableViewCell.self
        }
    }
}


class MainTableViewCell: UITableViewCell {
    
    class var cellHeight: CGFloat { return 0 }
    
}
