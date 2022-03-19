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
    
    var buttonImage: UIImage? {
        switch self {
        case .day:     return UIImage(named: "icn_dateview")
        case .journey: return UIImage(named: "icnJourneyview")
        }
    }
}

final class TodoViewModel {
    
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
    
    var loadingObservable: Observable<Bool> {
        self.loadingSubject.asObservable()
    }
    
    var currentDate: PolarisDate {
        MainSceneDateSelector.shared.selectedDate
    }
    
    // Should Scroll 포함해서 Scroll 해야하는 경우
    let reloadSubject   = PublishSubject<Bool>()
    let currentTabRelay = BehaviorRelay<TodoCategory>(value: .day)
    
    init(todoRepository: TodoRepository = TodoRepositoryImpl()) {
        self.todoRepository = todoRepository
        self.observe(viewEvent: self.viewEventRelay)
        self.observe(mainDateSelector: MainSceneDateSelector.shared)
    }
    
    func occur(viewEvent: ViewEvent) {
        self.viewEventRelay.accept(viewEvent)
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
    
    func requestTodoJourneyList(ofDate date: PolarisDate) {
        self.todoRepository.fetchTodoJourneyList(ofDate: date)
            .withUnretained(self)
            .subscribe(onNext: { owner, todoListModel in
                owner.todoJourneyList = todoListModel.data
                
                guard owner.currentTabRelay.value == .journey else { return }
                owner.reloadSubject.onNext(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    func requestTodoDayList(ofDate date: PolarisDate, shouldScroll: Bool) {
        self.todoRepository.fetchTodoDayList(ofDate: date)
            .withUnretained(self)
            .subscribe(onNext: { owner, todoListModel in
                owner.updateTodoDayListModel(todoListModel)
                
                guard owner.currentTabRelay.value == .day else { return }
                owner.reloadSubject.onNext(shouldScroll)
            })
            .disposed(by: self.disposeBag)
    }
    
    func requestAddTodo(_ todoModel: TodoModel) {
        guard let requestBody = todoModel.addTodoRequestBody else { return }

        self.loadingSubject.onNext(true)
        self.todoRepository.createTodo(requestBody: requestBody)
            .withUnretained(self)
            .subscribe(onNext: { owner, responseModel in
                owner.reloadTodoList(ofDate: owner.currentDate)
                
                owner.loadingSubject.onNext(false)
                NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
            }, onError: { [weak self] _ in
                self?.loadingSubject.onNext(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    func requestDeleteTodo(_ todoIdx: Int, completion: @escaping () -> Void) {
        self.loadingSubject.onNext(true)
        self.todoRepository.deleteTodo(todoIdx: todoIdx)
            .withUnretained(self)
            .subscribe(onNext: { owner, successModel in
                owner.loadingSubject.onNext(false)
                
                guard successModel.isSuccess == true else { return }
                owner.reloadTodoList(ofDate: owner.currentDate)
                completion()
                NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
            }, onError: { [weak self] _ in
                self?.loadingSubject.onNext(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    func updateDoneStatus(_ todoModel: TodoModel) {
        guard let todoIdx = todoModel.idx else { return }
        
        let edittedIsDone = todoModel.isDone == nil ? true : false
        let todoEditAPI   = TodoAPI.editTodo(idx: todoIdx, isDone: edittedIsDone)
        
        self.loadingSubject.onNext(true)
        NetworkManager.request(apiType: todoEditAPI).subscribe(onSuccess: { [weak self] (responseModel: TodoModel) in
            guard let self = self else { return }
            self.loadingSubject.onNext(false)
            
            self.reloadTodoList(ofDate: self.currentDate)
            NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
        }, onFailure: { [weak self] _ in
            self?.loadingSubject.onNext(false)
        }).disposed(by: self.disposeBag)
    }
    
    private func observe(mainDateSelector: MainSceneDateSelector) {
        mainDateSelector.selectedDateObservable
            .compactMap { $0 }
            .map { .selectDate($0) }
            .bind(to: self.viewEventRelay)
            .disposed(by: self.disposeBag)
    }
    
    private func observe(viewEvent: PublishRelay<ViewEvent>) {
        viewEvent
            .withUnretained(self)
            .subscribe(onNext: { owner, event in
                switch event {
                case .selectDate(let date):
                    self.updateWeeksHeaderInform(ofDate: date)
                    self.reloadTodoList(ofDate: date)
                    
                case .notifyUpdateTodo(let scene):
                    self.reloadTodoListIfNeeded(asScene: scene)
                    
                }
            })
            .disposed(by: self.disposeBag)
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
    
    private func updateWeeksHeaderInform(ofDate date: PolarisDate) {
        self.todoDayHeadersInform = date.thisWeekDates
        self.todoDayHeadersInform.forEach {
            self.todoDayListTable.updateValue([], forKey: $0)
        }
    }
    
    private func reloadTodoList(ofDate date: PolarisDate) {
        self.requestTodoJourneyList(ofDate: date)
        self.requestTodoDayList(ofDate: date, shouldScroll: false)
    }
    
    private func reloadTodoListIfNeeded(asScene scene: String) {
        guard scene != MainSceneCellType.todoList.sceneIdentifier else { return }
        self.reloadTodoList(ofDate: self.currentDate)
    }
    
    private let todoRepository: TodoRepository

    
    // 날짜별 할일 보여줄 때, 사용하는 Property
    private(set) var dayExpandedTodo: TodoModel?
    private(set) var todoDayHeadersInform = [Date]()
    private(set) var todoDayListTable = [Date: [TodoModel]]()
    
    // 여정별 할일 보여줄 때, 사용하는 Property
    private(set) var journeyExpandedTodo: TodoModel?
    private(set) var todoJourneyList = [WeekJourneyModel]()
    
    private let viewEventRelay = PublishRelay<ViewEvent>()
    private let loadingSubject = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    
}

extension TodoViewModel {
    
    enum ViewEvent {
        case selectDate(PolarisDate)
        case notifyUpdateTodo(scene: String)
    }
    
}
