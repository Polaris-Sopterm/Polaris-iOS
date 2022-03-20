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
    
    func fetchTodoDayList(ofDate date: PolarisDate, completion: (([TodoDayListPresentationModel]) -> Void)? = nil) {
        self.todoRepository.fetchTodoDayList(ofDate: date)
            .withUnretained(self)
            .subscribe(onNext: { owner, todoListModel in
                let sectionModel = todoListModel.data ?? []
                let presentationList = owner.convertDayPresentationModel(from: sectionModel, ofDate: date)
                
                owner.daySections = presentationList
                completion?(presentationList)
            })
            .disposed(by: self.disposeBag)
    }
    
    func fetchTodoJourneyList(ofDate date: PolarisDate, completion: (([WeekJourneyModel]) -> Void)? = nil) {
        self.todoRepository.fetchTodoJourneyList(ofDate: date)
            .withUnretained(self)
            .subscribe(onNext: { owner, todoListModel in
                owner.journeySections = todoListModel.data
                completion?(todoListModel.data)
            })
            .disposed(by: self.disposeBag)
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
            .withUnretained(self)
            .subscribe(onNext: { owner, successModel in
                completion(successModel.isSuccess ?? false)
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
