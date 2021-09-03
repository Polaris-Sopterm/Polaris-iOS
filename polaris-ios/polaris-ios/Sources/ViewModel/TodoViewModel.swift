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
    
    // Should Scroll 포함해서 Scroll 해야하는 경우
    let reloadSubject   = PublishSubject<Bool>()
    let currentTabRelay = BehaviorRelay<TodoCategory>(value: .day)
    
    init() {
        self.todoDayHeadersInform = Date.daysThisWeek
        self.todoDayHeadersInform.forEach { self.todoDayListTable.updateValue([], forKey: $0) }
    }
    
    func updateCurrentTab(_ tab: TodoCategory) {
        self.currentTabRelay.accept(tab)
    }
    
    func isEmptyDayTodoSection(at section: Int) -> Bool {
        let currentTab = self.currentTabRelay.value
        
        guard currentTab == .day else { return false }
        let todoDayList = self.todoList(at: section)
        return todoDayList.count == 0 ? true : false
    }
    
    // 전부 현재 Selected Tab 기준으로 받아옴
    func todoListNumberOfRows(in section: Int) -> Int {
        if self.currentTabRelay.value == .day {
            guard let todoDate = self.todoDayHeadersInform[safe: section] else { return 1 }
            guard let todoList = self.todoDayListTable[todoDate]          else { return 1 }
            return todoList.count != 0 ? todoList.count : 1
        } else {
            guard let todoJoruney = self.todoJourneyList[safe: section] else { return 0 }
            guard let todoList = todoJoruney.toDos else                      { return 0 }
            return todoList.count
        }
    }
    
    // 전부 현재 Selected Tab 기준으로 받아옴
    func todoList(at section: Int) -> [TodoModel] {
        if self.currentTabRelay.value == .day {
            guard let todoDate = self.todoDayHeadersInform[safe: section] else { return [] }
            guard let todoList = self.todoDayListTable[todoDate]          else { return [] }
            return todoList
        } else {
            guard let todoJoruney = self.todoJourneyList[safe: section] else { return [] }
            guard let todoList = todoJoruney.toDos else                      { return [] }
            return todoList
        }
    }
    
    func expanedCellIndexPath(of tab: TodoCategory) -> IndexPath? {
        switch tab {
        case .day:     return self.dayExpanedIndexPath
        case .journey: return self.journeyExpanedIndexPath
        }
    }
    
    func updateExpanedStatus(category: TodoCategory, forRowAt indexPath: IndexPath, isExpanded: Bool) {
        switch category {
        case .day:     self.dayExpanedIndexPath = isExpanded ? indexPath : nil
        case .journey: self.journeyExpanedIndexPath = isExpanded ? indexPath : nil
        }
    }
    
    func requestAddTodo(_ todoModel: TodoModel) {
        guard let title = todoModel.title             else { return }
        guard let date = todoModel.date               else { return }
        guard let isTop = todoModel.isTop             else { return }
        let journeyIdx = todoModel.journey?.idx
        
        let createTodoAPI = TodoAPI.createToDo(title: title, date: date, journeyIdx: journeyIdx, isTop: isTop)
        NetworkManager.request(apiType: createTodoAPI).subscribe(onSuccess: { [weak self] (responseModel: AddTodoResponseModel) in
            self?.requestTodoJourneyList()
            self?.requestTodoDayList(shouldScroll: false)
            
            NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
        }).disposed(by: self.disposeBag)
    }
    
    func requestTodoJourneyList() {
        let todoListAPI = TodoAPI.listTodoByJourney(year: Date.currentYear,
                                                    month: Date.currentMonth,
                                                    weekNo: Date.currentWeekNoOfMonth)
        NetworkManager.request(apiType: todoListAPI).subscribe(onSuccess: { [weak self] (todoListModel: [WeekJourneyModel]) in
            self?.todoJourneyList = todoListModel
            
            guard self?.currentTabRelay.value == .journey else { return }
            self?.reloadSubject.onNext(false)
        }).disposed(by: self.disposeBag)
    }
    
    func requestTodoDayList(shouldScroll: Bool) {
        let todoListAPI = TodoAPI.listTodoByDate(year: Date.currentYear,
                                                 month: Date.currentMonth,
                                                 weekNo: Date.currentWeekNoOfMonth)
        NetworkManager.request(apiType: todoListAPI).subscribe(onSuccess: { [weak self] (todoListModel: TodoDayListModel) in
            self?.updateTodoDayListModel(todoListModel)
            
            guard self?.currentTabRelay.value == .day else { return }
            self?.reloadSubject.onNext(shouldScroll)
        }).disposed(by: self.disposeBag)
    }
    
    func requestDeleteTodo(_ todoIdx: Int, completion: @escaping () -> Void) {
        guard self.requestingDelete == false else { return }
        
        let todoDayDeleteAPI = TodoAPI.deleteTodo(idx: todoIdx)
        
        self.requestingDelete = true
        NetworkManager.request(apiType: todoDayDeleteAPI).subscribe(onSuccess: { [weak self] (successModel: SuccessModel) in
            guard let self = self else { return }
            self.requestingDelete = false
            
            guard successModel.isSuccess == true else { return }
            
            self.requestTodoJourneyList()
            self.requestTodoDayList(shouldScroll: false)
            completion()
            
            NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
        }, onFailure: { [weak self] _ in
            self?.requestingDelete = false
        }).disposed(by: self.disposeBag)
    }
    
    func updateDoneStatus(_ todoModel: TodoModel) {
        guard self.requestingDone == false else { return }
        guard let todoIdx = todoModel.idx  else { return }
        
        let edittedIsDone = todoModel.isDone == nil ? true : false
        let todoEditAPI   = TodoAPI.editTodo(idx: todoIdx, isDone: edittedIsDone)
        
        self.requestingDone = true
        NetworkManager.request(apiType: todoEditAPI).subscribe(onSuccess: { [weak self] (responseModel: TodoModel) in
            guard let self = self else { return }
            self.requestingDone = true
            
            self.requestTodoDayList(shouldScroll: false)
            self.requestTodoJourneyList()
            
            NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
        }, onFailure: { [weak self] _ in
            self?.requestingDone = false
        }).disposed(by: self.disposeBag)
    }
    
    private func updateTodoDayListModel(_ todoListModel: TodoDayListModel) {
        self.todoDayHeadersInform.forEach { todoHeader in
            let todoModelForHeader = todoListModel.data?.first(where: { todoModel in
                guard let todoDate = todoModel.day?.convertToDate()?.normalizedDate else { return false }
                return todoDate == todoHeader
            })
            
            self.todoDayListTable[todoHeader] = todoModelForHeader?.todoList ?? []
        }
    }
    
    private var requestingDelete: Bool = false
    private var requestingDone: Bool   = false
    
    /*
     날짜별 할일 보여줄 때, 사용하는 Property
     - Date 업데이트 시킬 때, 12:00:00으로 맞추어서 Normalized 시킴
     */
    private(set) var dayExpanedIndexPath: IndexPath?
    private(set) var todoDayHeadersInform: [Date]
    private(set) var todoDayListTable = [Date: [TodoModel]]()
    
    /*
     여정별 할일 보여줄 때, 사용하는 Property
     */
    private(set) var journeyExpanedIndexPath: IndexPath?
    private(set) var todoJourneyList = [WeekJourneyModel]()
    
    private let disposeBag = DisposeBag()
    
}
