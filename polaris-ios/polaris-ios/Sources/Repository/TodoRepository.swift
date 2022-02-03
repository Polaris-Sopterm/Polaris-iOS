//
//  TodoRepository.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/29.
//

import RxSwift
import Foundation

protocol TodoRepository {
    func fetchTodoDayList(ofDate date: PolarisDate) -> Observable<TodoDayListModel>
    func fetchTodoJourneyList(ofDate date: PolarisDate) -> Observable<TodoJourneyListModel>
}

final class TodoRepositoryImpl: TodoRepository {
    
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
