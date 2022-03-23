//
//  TodoHeaderModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/07/22.
//

import Foundation

struct TodoDayListModel: Codable {
    let data: [TodoDaySectionModel]?
}

struct TodoDaySectionModel: Codable {
    let day: String?
    let todoList: [TodoModel]?
}

struct TodoModel: Codable {
    let idx: Int?
    let title: String?
    let isTop: Bool?
    var isDone: String?
    let date: String?
    let createdAt: String?
    let journey: JourneyTitleModel?
}

extension TodoModel {
    
    var addTodoRequestBody: AddTodoRequestBody? {
        guard let title = self.title else { return nil }
        guard let date = self.date   else { return nil }
        guard let isTop = self.isTop else { return nil }
        let journeyIdx = self.journey?.idx
        return AddTodoRequestBody(title: title, date: date, isTop: isTop, journeyIdx: journeyIdx)
    }
    
}
