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
    
    var dayExpandedTodoIndexPath: IndexPath? {
        guard let date = self.dayExpandedTodo?.date?.convertToDate()?.normalizedDate        else { return nil }
        guard let section = self.todoDayHeadersInform.firstIndex(of: date)                  else { return nil }
        guard let todoList = self.todoDayListTable[date]                                    else { return nil }
        guard let row = todoList.firstIndex(where: { $0.idx == self.dayExpandedTodo?.idx }) else { return nil }
        return IndexPath(row: row, section: section)
    }
    
    var journeyExpandedTodoIndexPath: IndexPath? {
        guard let expandedTodo = self.journeyExpandedTodo else { return nil }
        guard let section = expandedTodo.journey?.idx == nil ?
                self.todoJourneyList.firstIndex(where: { $0.title == "default" }) :
                self.todoJourneyList.firstIndex(where: { $0.idx == expandedTodo.idx})        else { return nil }
        guard let todos = self.todoJourneyList[safe: section]?.toDos                         else { return nil }
        guard let row = todos.firstIndex(where: { $0.idx == self.journeyExpandedTodo?.idx }) else { return nil }
        return IndexPath(row: row, section: section)
    }
    
    // Should Scroll 포함해서 Scroll 해야하는 경우
    let reloadSubject   = PublishSubject<Bool>()
    let currentTabRelay = BehaviorRelay<TodoCategory>(value: .day)
    
    init(weekRepository: WeekRepository = WeekRepositoryImpl()) {
        self.weekRepository = weekRepository
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
    
    func updateExpandedStatus(category: TodoCategory, forTodo todo: TodoModel, isExpanded: Bool) {
        switch category {
        case .day:     self.dayExpandedTodo = isExpanded ? todo : nil
        case .journey: self.journeyExpandedTodo = isExpanded ? todo : nil
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
        self.weekRepository.fetchWeekNo(ofDate: Date.normalizedCurrent)
            .flatMapLatest { weekNo -> Observable<[WeekJourneyModel]> in
                let todoListAPI = TodoAPI.listTodoByJourney(
                    year: Date.currentYear,
                    month: Date.currentMonth,
                    weekNo: weekNo
                )
                return NetworkManager.request(apiType: todoListAPI).asObservable()
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, todoListModel in
                owner.todoJourneyList = todoListModel
                
                guard owner.currentTabRelay.value == .journey else { return }
                owner.reloadSubject.onNext(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    func requestTodoDayList(shouldScroll: Bool) {
        self.weekRepository.fetchWeekNo(ofDate: Date.normalizedCurrent)
            .flatMapLatest { weekNo -> Observable<TodoDayListModel> in
                let todoListAPI = TodoAPI.listTodoByDate(
                    year: Date.currentYear,
                    month: Date.currentMonth,
                    weekNo: weekNo
                )
                return NetworkManager.request(apiType: todoListAPI).asObservable()
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, todoListModel in
                owner.updateTodoDayListModel(todoListModel)
                
                guard owner.currentTabRelay.value == .day else { return }
                owner.reloadSubject.onNext(shouldScroll)
            })
            .disposed(by: self.disposeBag)
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
            self.requestingDone = false
            
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
    
    private let weekRepository: WeekRepository
    
    private var requestingDelete: Bool = false
    private var requestingDone: Bool   = false
    
    /*
     날짜별 할일 보여줄 때, 사용하는 Property
     - Date 업데이트 시킬 때, 12:00:00으로 맞추어서 Normalized 시킴
     */
    private(set) var dayExpandedTodo: TodoModel?
    private(set) var todoDayHeadersInform: [Date]
    private(set) var todoDayListTable = [Date: [TodoModel]]()
    
    /*
     여정별 할일 보여줄 때, 사용하는 Property
     */
    private(set) var journeyExpandedTodo: TodoModel?
    private(set) var todoJourneyList = [WeekJourneyModel]()
    
    private let disposeBag = DisposeBag()
    
}
