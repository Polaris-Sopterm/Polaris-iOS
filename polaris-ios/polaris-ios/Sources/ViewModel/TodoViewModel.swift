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
    
    let reloadSubject   = PublishSubject<Void>()
    let currentTabRelay = BehaviorRelay<TodoCategory>(value: .day)
    
    init() {
        self.todoDayHeadersInform.forEach { self.todoDayListTable.updateValue([], forKey: $0) }
    }
    
    func isEmptySection(at section: Int) -> Bool {
        let currentTab = self.currentTabRelay.value
        
        if currentTab == .day {
            let todoDayList = self.todoDayList(at: section)
            return todoDayList?.count == 0 || todoDayList == nil ? true : false
        } else {
            return false
        }
    }
    
    func todoDayList(at section: Int) -> [TodoDayPerModel]? {
        guard let todoDate = self.todoDayHeadersInform[safe: section] else { return nil }
        guard let todoList = self.todoDayListTable[todoDate]          else { return nil }
        return todoList
    }
    
    func requestTodoList() {
        let todoListAPI = TodoAPI.listTodoByDate()
        NetworkManager.request(apiType: todoListAPI).subscribe(onSuccess: { (todoListModel: TodoDayListModel) in
            self.updateTodoDayListModel(todoListModel)
        }, onFailure: { error in
            #warning("Error 처리 로직")
            print(error.localizedDescription)
        }).disposed(by: self.disposeBag)
    }
    
    func updateCurrentTab(_ tab: TodoCategory) {
        self.currentTabRelay.accept(tab)
    }
    
    private func updateTodoDayListModel(_ todoListModel: TodoDayListModel) {
        todoListModel.data?.forEach { todoList in
            guard let day = todoList.day                          else { return }
            guard let convertDate = day.convertToDate()           else { return }
            guard let normalizedDate = convertDate.normalizedDate else { return }
            guard todoDayListTable[normalizedDate] != nil         else { return }
            todoDayListTable[normalizedDate] = todoList.todoList
        }
        self.reloadSubject.onNext(())
    }
    
    // Date 업데이트 시킬 때, 12:00:00으로 맞추어서 Normalized 시킴
    private(set) var todoDayHeadersInform: [Date]                = Date.daysThisWeek
    private(set) var todoDayListTable: [Date: [TodoDayPerModel]] = [:]
    
    private let disposeBag = DisposeBag()
    
}
