//
//  TodoController.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/03/20.
//

import Foundation
import RxSwift

protocol TodoSectionHeaderPresentable {}

struct TodoDayListPresentationModel: TodoSectionHeaderPresentable {
    let date: Date
    let todoList: [TodoModel]
}

final class TodoController {
    
    var isEmptyJourneySections: Bool {
        self.journeySections.isEmpty
    }
    
    init(todoRepository: TodoRepository = TodoRepositoryImpl()) {
        self.todoRepository = todoRepository
    }
    
    func fetchTodoDayList(ofDate date: PolarisDate) -> Observable<[TodoDayListPresentationModel]> {
        self.todoRepository.fetchTodoDayList(ofDate: date)
            .withUnretained(self)
            .map { owner, todoListModel in
                let sectionModel = todoListModel.data ?? []
                let presentationList = owner.convertDayPresentationModel(from: sectionModel, ofDate: date)
                return presentationList
            }
            .do(onNext: { [weak self] presentationList in
                self?.daySections = presentationList
            })
    }
    
    func fetchTodoJourneyList(ofDate date: PolarisDate) -> Observable<[WeekJourneyModel]> {
        self.todoRepository.fetchTodoJourneyList(ofDate: date)
            .map { $0.data }
            .map { journeySections in
                var newJourenySections = [WeekJourneyModel]()
                
                for index in 0..<journeySections.count {
                    guard var section = journeySections[safe: index] else { continue }
                    
                    let journeyTitleModel = section.journeyTitleModel
                    let newTodos = section.toDos?.map { todo -> TodoModel in
                        var todo = todo
                        todo.journey = journeyTitleModel
                        return todo
                    }
                    
                    section.toDos = newTodos
                    newJourenySections.append(section)
                }
                return newJourenySections
            }
            .do(onNext: { [weak self] journeySections in
                self?.journeySections = journeySections
            })
    }
        
    func addTodo(_ todoModel: TodoModel, completion: @escaping (Bool) -> Void) {
        guard let requestBody = todoModel.addTodoRequestBody else { return }
        self.todoRepository.createTodo(requestBody: requestBody)
            .subscribe(onNext: { _ in
                completion(true)
            }, onError: { _ in
                completion(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    func deleteTodo(ofIdx idx: Int, completion: @escaping (Bool) -> Void) {
        self.todoRepository.deleteTodo(todoIdx: idx)
            .subscribe(onNext: { successModel in
                completion(successModel.isSuccess ?? false)
            }, onError: { _ in
                completion(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    func editDoneStatus(_ todoModel: TodoModel, completion: @escaping (Bool) -> Void) {
        guard let todoIdx = todoModel.idx else { return }
        
        let edittedIsDone = todoModel.isDone == nil ? true : false
        self.todoRepository.editTodo(todoIdx: todoIdx, isDone: edittedIsDone)
            .subscribe(onNext: { todoModel in
                completion(true)
            }, onError: { _ in
                completion(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func convertDayPresentationModel(from sectionModel: [TodoDaySectionModel], ofDate date: PolarisDate) -> [TodoDayListPresentationModel] {
        let thisWeeksDates = date.thisWeekDates
        
        var presentationList = [TodoDayListPresentationModel]()
        thisWeeksDates.forEach { date in
            let sectionList = sectionModel.first(where: { todoModel in
                guard let todoDate = todoModel.day?.convertToDate()?.normalizedDate else { return false }
                return todoDate == date
            })?.todoList ?? []
            
            let presentationModel = TodoDayListPresentationModel(date: date, todoList: sectionList)
            presentationList.append(presentationModel)
        }
        return presentationList
    }
    
    private(set) var daySections = [TodoDayListPresentationModel]()
    private(set) var journeySections = [WeekJourneyModel]()
    
    private let disposeBag = DisposeBag()
    private let todoRepository: TodoRepository
    
}
