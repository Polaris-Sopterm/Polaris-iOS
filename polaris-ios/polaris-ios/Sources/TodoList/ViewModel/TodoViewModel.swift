//
//  TodoViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/18.
//

import Foundation
import RxSwift
import RxRelay

final class TodoViewModel {
    
    var dayExpandedTodoIndexPath: IndexPath? {
        guard let date = self.dayExpandedTodo?.date?.convertToDate()?.normalizedDate else { return nil }
        
        let sectionModel = self.todoController.daySections
        guard let section = sectionModel.firstIndex(where: { $0.date == date })             else { return nil }
        guard let todoList = sectionModel[safe: section]?.todoList                          else { return nil }
        guard let row = todoList.firstIndex(where: { $0.idx == self.dayExpandedTodo?.idx }) else { return nil }
        return IndexPath(row: row, section: section)
    }
    
    var journeyExpandedTodoIndexPath: IndexPath? {
        guard let expandedTodo = self.journeyExpandedTodo else { return nil }
        
        let sectionModel = self.todoController.journeySections
        guard let section = expandedTodo.journey?.idx == nil ?
                    sectionModel.firstIndex(where: { $0.title == "default" }) :
                    sectionModel.firstIndex(where: { $0.idx == expandedTodo.idx })           else { return nil }
        guard let todos = sectionModel[safe: section]?.toDos                                 else { return nil }
        guard let row = todos.firstIndex(where: { $0.idx == self.journeyExpandedTodo?.idx }) else { return nil }
        return IndexPath(row: row, section: section)
    }
    
    var isEmptyJourneySections: Bool {
        self.todoController.isEmptyJourneySections
    }
    
    var currentDate: PolarisDate {
        MainSceneDateSelector.shared.selectedDate
    }
    
    var outputEventObservable: Observable<OutputEvent> {
        self.outputEventRelay.asObservable()
    }
    
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
    
    func numberOfSections() -> Int {
        if self.currentTabRelay.value == .day {
            return WeekDay.allCases.count
        } else {
            return self.todoController.journeySections.count
        }
    }
    
    func todoListNumberOfRows(in section: Int) -> Int {
        if self.currentTabRelay.value == .day {
            let sections = self.todoController.daySections
            guard let todoList = sections[safe: section]?.todoList else { return 1 }
            return todoList.count != 0 ? todoList.count : 1
        } else {
            let sections = self.todoController.journeySections
            guard let todoJoruney = sections[safe: section] else { return 0 }
            guard let todoList = todoJoruney.toDos          else { return 0 }
            return todoList.count
        }
    }
    
    func todoList(at section: Int) -> [TodoModel] {
        if self.currentTabRelay.value == .day {
            let sections = self.todoController.daySections
            return sections[safe: section]?.todoList ?? []
        } else {
            let sections = self.todoController.journeySections
            return sections[safe: section]?.toDos ?? []
        }
    }
    
    func headerModel(of section: Int) -> TodoSectionHeaderPresentable? {
        if self.currentTabRelay.value == .day {
            return self.todoController.daySections[safe: section]
        } else {
            return self.todoController.journeySections[safe: section]
        }
    }
    
    func daySection(ofDate date: Date) -> Int {
        self.todoController.daySections.firstIndex(where: { $0.date == date }) ?? 0
    }
    
    func updateExpandedStatus(category: TodoCategory, forTodo todo: TodoModel, isExpanded: Bool) {
        switch category {
        case .day:     self.dayExpandedTodo = isExpanded ? todo : nil
        case .journey: self.journeyExpandedTodo = isExpanded ? todo : nil
        }
    }
    
    func updateDoneStatus(_ todoModel: TodoModel) {
        guard let todoIdx = todoModel.idx else { return }
        
        let edittedIsDone = todoModel.isDone == nil ? true : false
        let todoEditAPI   = TodoAPI.editTodo(idx: todoIdx, isDone: edittedIsDone)
        
        self.outputEventRelay.accept(.loading(true))
        NetworkManager.request(apiType: todoEditAPI).subscribe(onSuccess: { [weak self] (responseModel: TodoModel) in
            guard let self = self else { return }
            self.outputEventRelay.accept(.loading(false))
            
            self.reloadTodoList(ofDate: self.currentDate)
            NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
        }, onFailure: { [weak self] _ in
            self?.outputEventRelay.accept(.loading(false))
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
                owner.handleViewEvent(event)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .selectDate(let date):
            self.reloadTodoList(ofDate: date)
            
        case .notifyUpdateTodo(let scene):
            self.reloadTodoListIfNeeded(asScene: scene)
            
        case .deleteBtnTapped(let todo):
            self.deleteTodo(todo: todo)
            
        case .addToastTapped(let todo):
            self.addTodo(todo: todo)
        }
    }
    
    private func addTodo(todo: TodoModel) {
        self.outputEventRelay.accept(.loading(true))
        self.todoController.addTodo(todo) { [weak self] isSuccess in
            guard let self = self else { return }
            defer { self.outputEventRelay.accept(.loading(false)) }
            
            guard isSuccess == true else { return }
            self.outputEventRelay.accept(.reload(shouldScroll: false))
            NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
        }
    }
    
    private func deleteTodo(todo: TodoModel) {
        guard let todoIdx = todo.idx else { return }
        
        self.outputEventRelay.accept(.loading(true))
        self.todoController.deleteTodo(ofIdx: todoIdx) { [weak self] isSuccess in
            guard let self = self else { return }
            defer { self.outputEventRelay.accept(.loading(false)) }
            
            guard isSuccess == true else { return }
            self.outputEventRelay.accept(.completeDelete(todo: todo))
            self.outputEventRelay.accept(.reload(shouldScroll: false))
            NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
        }
    }
    
    private func reloadTodoList(ofDate date: PolarisDate) {
        self.fetchTodoDayList(ofDate:  date)
        self.fetchTodoJourneyList(ofDate: date)
    }
    
    private func fetchTodoDayList(ofDate date: PolarisDate) {
        self.todoController.fetchTodoDayList(ofDate: date) { [weak self] _ in
            guard let self = self                    else { return }
            guard self.currentTabRelay.value == .day else { return }
            self.outputEventRelay.accept(.reload(shouldScroll: false))
        }
    }
    
    private func fetchTodoJourneyList(ofDate date: PolarisDate) {
        self.todoController.fetchTodoJourneyList(ofDate: date) { [weak self] _ in
            guard let self = self                        else { return }
            guard self.currentTabRelay.value == .journey else { return }
            self.outputEventRelay.accept(.reload(shouldScroll: false))
        }
    }
    
    private func reloadTodoListIfNeeded(asScene scene: String) {
        guard scene != MainSceneCellType.todoList.sceneIdentifier else { return }
        self.reloadTodoList(ofDate: self.currentDate)
    }
    
    private let todoRepository: TodoRepository

    // 날짜별 할일 보여줄 때, 사용하는 Property
    private(set) var dayExpandedTodo: TodoModel?
    
    // 여정별 할일 보여줄 때, 사용하는 Property
    private(set) var journeyExpandedTodo: TodoModel?
    
    private let disposeBag = DisposeBag()
    private let outputEventRelay = PublishRelay<OutputEvent>()
    private let viewEventRelay = PublishRelay<ViewEvent>()
    private let todoController = TodoController()
    
}

extension TodoViewModel: AddTodoViewControllerDelegate {
    
    func addTodoViewController(_ viewController: AddTodoVC, didCompleteAddOption option: AddTodoVC.AddOptions) {
        self.reloadTodoList(ofDate: self.currentDate)
        NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.todoList.sceneIdentifier)
    }
    
}

extension TodoViewModel {
    
    enum ViewEvent {
        case selectDate(PolarisDate)
        case notifyUpdateTodo(scene: String)
        case deleteBtnTapped(todo: TodoModel)
        case addToastTapped(todo: TodoModel)
    }
    
    enum OutputEvent {
        case loading(Bool)
        case completeDelete(todo: TodoModel)
        case reload(shouldScroll: Bool)
    }
    
}
