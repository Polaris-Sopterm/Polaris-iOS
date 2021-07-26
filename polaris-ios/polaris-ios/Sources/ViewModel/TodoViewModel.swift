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
    
    let currentTabRelay = BehaviorRelay<TodoCategory>(value: .day)
    let todoListModel   = BehaviorRelay<TodoDayListModel?>(value: nil)
    
    init() {
        self.todoDayHeaderModel = Date.daysThisWeek
        self.todoDayHeaderModel.forEach { self.todoDayListTable.updateValue([], forKey: $0) }
    }
    
    func requestTodoList() {
        let todoListAPI = TodoAPI.listTodoByDate(year: "2021", month: "7", weekNo: "4")
        NetworkManager.request(apiType: todoListAPI).subscribe(onSuccess: { (todoListModel: TodoDayListModel) in
            print(todoListModel)
        }, onFailure: { error in
            print(error.localizedDescription)
        }).disposed(by: self.disposeBag)
    }
    
    private(set) var todoDayHeaderModel: [Date]
    private(set) var todoDayListTable: [Date: [TodoDayPerModel]] = [:]
    
    private let disposeBag = DisposeBag()
    
}
