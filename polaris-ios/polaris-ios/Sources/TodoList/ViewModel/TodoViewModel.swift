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
    
    init(todoRepository: TodoRepository = TodoRepositoryImpl()) {
        self.todoRepository = todoRepository
        self.observe(viewEvent: self.viewEventRelay)
        self.observe(mainDateSelector: MainSceneDateSelector.shared)
    }
    
    func occur(viewEvent: ViewEvent) {
        self.viewEventRelay.accept(viewEvent)
    }
    
    func isEmptyDayTodoSection(at section: Int) -> Bool {
        let currentTab = self.currentTab
        
        guard currentTab == .day else { return false }
        let todoDayList = self.todoList(at: section)
        return todoDayList.count == 0 ? true : false
    }
    
    func numberOfSections() -> Int {
        if self.self.currentTab == .day {
            return WeekDay.allCases.count
        } else {
            return self.todoController.journeySections.count
        }
    }
    
    func todoListNumberOfRows(in section: Int) -> Int {
        if self.self.currentTab == .day {
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
        if self.currentTab == .day {
            let sections = self.todoController.daySections
            return sections[safe: section]?.todoList ?? []
        } else {
            let sections = self.todoController.journeySections
            return sections[safe: section]?.toDos ?? []
        }
    }
    
    func headerModel(of section: Int) -> TodoSectionHeaderPresentable? {
        if self.currentTab == .day {
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
            self.reloadTodoList(ofDate: date, shouldScroll: self.isInitialRequest)
            self.isInitialRequest = false
            
        case .categoryBtnTapped:
            self.updateCategory()
            
        case .notifyUpdateTodo(let scene):
            self.reloadTodoListIfNeeded(asScene: scene)
            
        case .deleteBtnTapped(let todo):
            self.deleteTodo(todo)
            
        case .addToastTapped(let todo):
            self.addTodo(todo)
            
        case .checkBtnTapped(let todo):
            self.editTodo(todo)
        }
    }
    
    private func updateCategory() {
        let currentTab = self.currentTab
        let changedTab: TodoCategory = currentTab == .day ? .journey : .day
        self.currentTab = changedTab
        self.outputEventRelay.accept(.updateCategory(changedTab))
    }
    
    private func addTodo(_ todo: TodoModel) {
        self.outputEventRelay.accept(.loading(true))
        self.todoController.addTodo(todo) { [weak self] isSuccess in
            guard let self = self else { return }
            defer { self.outputEventRelay.accept(.loading(false)) }
            
            guard isSuccess == true else { return }
            self.reloadTodoList(ofDate: self.currentDate, shouldScroll: false)
            NotificationCenter.default.postUpdateTodo(fromScene: .todoList)
        }
    }
    
    private func deleteTodo(_ todo: TodoModel) {
        guard let todoIdx = todo.idx else { return }
        
        self.outputEventRelay.accept(.loading(true))
        self.todoController.deleteTodo(ofIdx: todoIdx) { [weak self] isSuccess in
            guard let self = self else { return }
            defer { self.outputEventRelay.accept(.loading(false)) }
            
            guard isSuccess == true else { return }
            self.outputEventRelay.accept(.completeDelete(todo: todo))
            self.reloadTodoList(ofDate: self.currentDate, shouldScroll: false)
            NotificationCenter.default.postUpdateTodo(fromScene: .todoList)
        }
    }
    
    private func editTodo(_ todo: TodoModel) {
        self.outputEventRelay.accept(.loading(true))
        self.todoController.editDoneStatus(todo) { [weak self] isSuccess in
            guard let self = self else { return }
            defer { self.outputEventRelay.accept(.loading(false)) }
            
            self.reloadTodoList(ofDate: self.currentDate, shouldScroll: false)
            NotificationCenter.default.postUpdateTodo(fromScene: .todoList)
        }
    }
    
    private func reloadTodoList(ofDate date: PolarisDate, shouldScroll: Bool) {
        let dayListObservable = self.todoController.fetchTodoDayList(ofDate: date)
        let journeyListObservable = self.todoController.fetchTodoJourneyList(ofDate: date)
        
        self.outputEventRelay.accept(.loading(true))
        Observable.zip(dayListObservable, journeyListObservable)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.outputEventRelay.accept(.loading(false))
                owner.outputEventRelay.accept(.reload(shouldScroll: shouldScroll))
            }, onError: { [weak self] _ in
                self?.outputEventRelay.accept(.loading(false))
            })
            .disposed(by: self.disposeBag)
    }
        
    private func reloadTodoListIfNeeded(asScene scene: String) {
        guard scene != MainSceneCellType.todoList.sceneIdentifier else { return }
        self.reloadTodoList(ofDate: self.currentDate, shouldScroll: false)
    }
    
    private let todoRepository: TodoRepository

    // 날짜별 할일 보여줄 때, 사용하는 Property
    private(set) var dayExpandedTodo: TodoModel?
    
    // 여정별 할일 보여줄 때, 사용하는 Property
    private(set) var journeyExpandedTodo: TodoModel?
    
    private(set) var currentTab: TodoCategory = .day
    
    private var isInitialRequest = true
    private let disposeBag = DisposeBag()
    private let outputEventRelay = PublishRelay<OutputEvent>()
    private let viewEventRelay = PublishRelay<ViewEvent>()
    private let todoController = TodoController()
    
}

extension TodoViewModel: AddTodoViewControllerDelegate {
    
    func addTodoViewController(_ viewController: AddTodoVC, didCompleteAddOption option: AddTodoVC.AddOptions) {
        self.reloadTodoList(ofDate: self.currentDate, shouldScroll: false)
        NotificationCenter.default.postUpdateTodo(fromScene: .todoList)
    }
    
}

extension TodoViewModel {
    
    enum ViewEvent {
        case selectDate(PolarisDate)
        case notifyUpdateTodo(scene: String)
        case deleteBtnTapped(todo: TodoModel)
        case addToastTapped(todo: TodoModel)
        case categoryBtnTapped
        case checkBtnTapped(todo: TodoModel)
    }
    
    enum OutputEvent {
        case loading(Bool)
        case completeDelete(todo: TodoModel)
        case reload(shouldScroll: Bool)
        case updateCategory(TodoCategory)
    }
    
}
