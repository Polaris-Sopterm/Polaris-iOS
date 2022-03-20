//
//  TodoCategory.swift
//  Polaris
//
//  Created by Dongmin on 2022/03/20.
//

import UIKit

enum TodoCategory {
    case day
    case journey
    
    var title: String {
        switch self {
        case .day:      return "날짜 별 할일 보기"
        case .journey:  return "여정 별 할일 보기"
        }
    }
    
    var cellType: TodoCategoryCell.Type {
        switch self {
        case .day:     return DayTodoTableViewCell.self
        case .journey: return JourneyTodoTableViewCell.self
        }
    }
    
    var headerType: TodoHeaderView.Type {
        switch self {
        case .day:     return DayTodoHeaderView.self
        case .journey: return JourneyTodoHeaderView.self
        }
    }
    
    var buttonImage: UIImage? {
        switch self {
        case .day:     return UIImage(named: "icn_dateview")
        case .journey: return UIImage(named: "icnJourneyview")
        }
    }
}
