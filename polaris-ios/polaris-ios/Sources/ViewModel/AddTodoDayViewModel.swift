//
//  AddTodoDayViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import Foundation
import RxSwift

class AddTodoDayViewModel {
    var daysSubject: BehaviorSubject<[(weekday: String, day: Int)]> = {
        var thisWeek: [(weekday: String, day: Int)] = []
        
        Date.daysIncludedThisWeek.enumerated().forEach { index, day in
            var weekDayIndex: Int
            if index == 6 { weekDayIndex = 1 }
            else          { weekDayIndex = index + 2 }
            guard let weekday = Date.WeekDay(rawValue: weekDayIndex) else { return }
            
            thisWeek.append((weekday.korWeekday, day))
        }
        return BehaviorSubject<[(weekday: String, day: Int)]>(value: thisWeek)
    }()
}
