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
    let title: String?
    let year, month, weekNo: Int?
    let userIdx: Int?
    let value1, value2: String?
    var toDos: [TodoModel]?
}

extension WeekJourneyModel: TodoSectionHeaderPresentable {
    
    var firstValueJourney: Journey? {
        guard let value = self.value1 else { return nil }
        return Journey(rawValue: value)
    }
    
    var secondValueJourney: Journey? {
        guard let value = self.value2 else { return nil }
        return Journey(rawValue: value)
    }
    
    var journeyTitleModel: JourneyTitleModel {
        JourneyTitleModel(
            idx: self.idx,
            title: self.title,
            year: self.year,
            month: self.month,
            weekNo: self.weekNo,
            userIdx: self.userIdx
        )
    }
    
}

struct TodoJourneyListModel {
    let data: [WeekJourneyModel]
}
