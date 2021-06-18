//
//  TodoViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/18.
//

import Foundation
import RxSwift

enum TodoCategory {
    case day
    case journey
    
    var cellType: TodoCategoryCell.Type {
        switch self {
        case .day:     return DayTodoTableViewCell.self
        case .journey: return JourneyTodoTableViewCell.self
        }
    }
}

class TodoViewModel {
    
    let reloadSubject = PublishSubject<Void>()
    
    func update(tab: TodoCategory) {
        self.currentTab = tab
    }
    
    private(set) var currentTab: TodoCategory = .day
    
}
