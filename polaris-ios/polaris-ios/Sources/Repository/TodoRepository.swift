//
//  TodoRepository.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/29.
//

import RxSwift
import Foundation

protocol TodoRepository {
    func createTodo(requestBody: AddTodoRequestBody) -> Observable<AddTodoResponseModel>
    func deleteTodo(todoIdx: Int) -> Observable<SuccessModel>
    func editTodo(todoIdx: Int, isDone: Bool) -> Observable<TodoModel>
    func fetchTodoDayList(ofDate date: PolarisDate) -> Observable<TodoDayListModel>
    func fetchTodoJourneyList(ofDate date: PolarisDate) -> Observable<TodoJourneyListModel>
}

final class TodoRepositoryImpl: TodoRepository {
    
    func createTodo(requestBody: AddTodoRequestBody) -> Observable<AddTodoResponseModel> {
        let createTodoAPI = TodoAPI.createToDo(
            title: requestBody.title,
            date: requestBody.date,
            journeyIdx: requestBody.journeyIdx,
            isTop: requestBody.isTop
        )
        return NetworkManager.request(apiType: createTodoAPI)
            .asObservable()
    }
    
    func deleteTodo(todoIdx: Int) -> Observable<SuccessModel> {
        let deleteTodoAPI = TodoAPI.deleteTodo(idx: todoIdx)
        return NetworkManager.request(apiType: deleteTodoAPI)
            .asObservable()
    }
    
    func editTodo(todoIdx: Int, isDone: Bool) -> Observable<TodoModel> {
        let editAPI = TodoAPI.editTodo(idx: todoIdx, isDone: isDone)
        return NetworkManager.request(apiType: editAPI)
            .asObservable()
    }
    
    func fetchTodoDayList(ofDate date: PolarisDate) -> Observable<TodoDayListModel> {
        let todoListAPI = TodoAPI.listTodoByDate(
            year: date.year,
            month: date.month,
            weekNo: date.weekNo
        )
        return NetworkManager.request(apiType: todoListAPI)
            .asObservable()
    }
    
    func fetchTodoJourneyList(ofDate date: PolarisDate) -> Observable<TodoJourneyListModel> {
        let todoListAPI = TodoAPI.listTodoByJourney(
            year: date.year,
            month: date.month,
            weekNo: date.weekNo
        )
        return NetworkManager.request(apiType: todoListAPI)
            .map { (todoListModel: [WeekJourneyModel]) in
                TodoJourneyListModel(data: todoListModel)
            }
            .asObservable()
    }
    
}
