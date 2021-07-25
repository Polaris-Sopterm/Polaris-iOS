//
//  TodoViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/18.
//

import Foundation
import RxSwift
import RxRelay

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
}

class TodoViewModel {
    
    typealias DayTodoSectionModel = [[String]]
    
    let currentTabRelay = BehaviorRelay<TodoCategory>(value: .day)
    
    func requestTodoList() {
        let todoListAPI = TodoAPI.listTodoByDate(year: "2021", month: "7", weekNo: "4")
        
//        NetworkManager.request(apiType: todoListAPI)
    }
    
    private(set) var journeyTodoModel      = [String]()
    private(set) var jouneyTodoHeaderModel = [Date]()
    
    private(set) var dayTodoHeaderModel = [Date]()
    private(set) var dayTodoModel       = [String]()
    
}
