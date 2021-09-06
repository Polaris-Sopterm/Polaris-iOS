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
