//
//  TodoWeekListModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/07/31.
//

import Foundation

struct JourneyWeekListModel: Codable {
    let weekList: [WeekModel]?
    let journeys: [WeekJourneyModel]?
}

struct WeekModel: Codable {
    let year,month,weekNo: Int?
}

struct WeekJourneyModel: Codable {
    let idx: Int?
    let title, year, month, weekNo: String?
    let userIdx: Int?
    let value1, value2: String?
    let toDos: [WeekTodo]?
}

struct WeekTodo: Codable {
    let idx: Int?
    let title, date: String?
    let isTop: Bool?
    let isDone: String?
}


