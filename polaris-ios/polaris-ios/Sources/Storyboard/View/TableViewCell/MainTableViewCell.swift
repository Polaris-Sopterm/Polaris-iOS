//
//  MainTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/17.
//

import UIKit

enum MainSceneCellType: Int, CaseIterable {
    case retrospect = 0, main, todoList
    
    var cellType: MainTableViewCell.Type {
        switch self {
        case .retrospect: return RetrospectTableViewCell.self
        case .main:       return MainSceneTableViewCell.self
        case .todoList:   return TodoTableViewCell.self
        }
    }
    
    var sceneIdentifier: String {
        switch self {
        case .retrospect: return "Retrospect"
        case .main:       return "Main"
        case .todoList:   return "TodoList"
        }
    }
    
}


class MainTableViewCell: UITableViewCell {
    
    class var cellHeight: CGFloat { return 0 }
    
}
