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
    
    let reloadSubject   = PublishSubject<Bool>()
    let currentTabRelay = BehaviorRelay<TodoCategory>(value: .day)
    
    init() {
        self.todoDayHeadersInform = Date.daysThisWeek
        self.todoDayHeadersInform.forEach { self.todoDayListTable.updateValue([], forKey: $0) }
    }
    
    func isEmptySection(at section: Int) -> Bool {
        let currentTab = self.currentTabRelay.value
        
        if currentTab == .day {
            let todoDayList = self.todoDayList(at: section)
            return todoDayList.count == 0 ? true : false
        } else {
            return false
        }
    }
    
    // 전부 현재 Selected Tab 기준으로 받아옴
    func todoListNumberOfRows(in section: Int) -> Int {
        if self.currentTabRelay.value == .day {
            guard let todoDate = self.todoDayHeadersInform[safe: section] else { return 1 }
            guard let todoList = self.todoDayListTable[todoDate]          else { return 1 }
            return todoList.count != 0 ? todoList.count : 1
        } else {
            return 0
        }
    }
    
    // 전부 현재 Selected Tab 기준으로 받아옴
    func todoDayList(at section: Int) -> [TodoListModelProtocol] {
        if self.currentTabRelay.value == .day {
            guard let todoDate = self.todoDayHeadersInform[safe: section] else { return [] }
            guard let todoList = self.todoDayListTable[todoDate]          else { return [] }
            return todoList
        } else {
            return []
        }
    }
    
    func expanedCellIndexPath(of tab: TodoCategory) -> IndexPath? {
        switch tab {
        case .day:     return self.dayExpanedIndexPath
        case .journey: return nil
        }
    }
    
    func requestTodoDayList(shouldScroll: Bool) {
        let todoListAPI = TodoAPI.listTodoByDate()
        NetworkManager.request(apiType: todoListAPI).subscribe(onSuccess: { [weak self] (todoListModel: TodoDayListModel) in
            self?.updateTodoDayListModel(todoListModel)
            self?.reloadSubject.onNext(shouldScroll)
        }).disposed(by: self.disposeBag)
    }
    
    func requestDeleteTodoDay(_ todoIdx: Int) {
        #warning("여기에 서버에서 업데이트 해주는 모델 추가해서 받기")
        let todoDayDeleteAPI = TodoAPI.deleteTodo(idx: todoIdx)
        NetworkManager.request(apiType: todoDayDeleteAPI).subscribe(onSuccess: { [weak self] (result: String) in
            guard let self = self else { return }
            
            self.requestTodoDayList(shouldScroll: false)
        }, onFailure: { error in
            #warning("여기 지워야 함 - Reponse Model 나오면")
            self.requestTodoDayList(shouldScroll: false)
        }).disposed(by: self.disposeBag)
    }
    
    func updateCurrentTab(_ tab: TodoCategory) {
        self.currentTabRelay.accept(tab)
    }
    
    func updateDayExpanedStatus(forRowAt indexPath: IndexPath, isExpaned: Bool) {
        self.dayExpanedIndexPath = isExpaned ? indexPath : nil
    }
    
    func updateDoneStatus(_ todoModel: TodoDayPerModel) {
        guard let todoIdx = todoModel.idx                                  else { return }
        guard let header = todoModel.date?.convertToDate()?.normalizedDate else { return }
        
        let edittedIsDone = todoModel.isDone == nil ? true : false
        let todoEditAPI = TodoAPI.editTodo(idx: todoIdx, isDone: edittedIsDone)
        
        NetworkManager.request(apiType: todoEditAPI).subscribe(onSuccess: { [weak self] (responseModel: TodoDayPerModel) in
            guard let self = self else { return }
            self.requestTodoDayList(shouldScroll: false)
        }).disposed(by: self.disposeBag)
    }
    
    private func updateTodoDayListModel(_ todoListModel: TodoDayListModel) {
        todoListModel.data?.forEach { todoList in
            guard let day = todoList.day                          else { return }
            guard let convertDate = day.convertToDate()           else { return }
            guard let normalizedDate = convertDate.normalizedDate else { return }
            guard todoDayListTable[normalizedDate] != nil         else { return }
            todoDayListTable[normalizedDate] = todoList.todoList
        }
    }
    
    /*
     날짜별 할일 보여줄 때, 사용하는 Property
     - Date 업데이트 시킬 때, 12:00:00으로 맞추어서 Normalized 시킴
     */
    private(set) var dayExpanedIndexPath: IndexPath?
    private(set) var todoDayHeadersInform: [Date]
    private(set) var todoDayListTable: [Date: [TodoDayPerModel]] = [:]
    
    private let disposeBag = DisposeBag()
    
}
