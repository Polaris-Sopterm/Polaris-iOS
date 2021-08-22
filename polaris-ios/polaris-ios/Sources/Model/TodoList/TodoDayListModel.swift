//
//  TodoHeaderModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/07/22.
//

import Foundation

struct TodoDayListModel: Codable {
    let data: [TodoDayModel]?
}

struct TodoDayModel: Codable {
    let day: String?
    let todoList: [TodoDayPerModel]?
}

struct TodoDayPerModel: Codable, TodoModelProtocol {
    let idx: Int?
    let title: String?
    let isTop: Bool?
    var isDone: String?
    let date: String?
    let createdAt: String?
    let journey: JourneyTitleModel?
}
