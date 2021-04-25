//
//  AddTodoDayViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import Foundation
import RxSwift

class AddTodoDayViewModel {
    var daysSubject: BehaviorSubject<[(weekday: Date.WeekDay, day: Int)]> = {
        var thisWeek: [(weekday: Date.WeekDay, day: Int)] = []
        
        Date.daysIncludedThisWeek.enumerated().forEach { index, day in
            var weekDayIndex: Int
            if index == 6 { weekDayIndex = 1 }
            else          { weekDayIndex = index + 2 }
            guard let weekday = Date.WeekDay(rawValue: weekDayIndex) else { return }
            
            thisWeek.append((weekday, day))
        }
        return BehaviorSubject<[(weekday: Date.WeekDay, day: Int)]>(value: thisWeek)
    }()
    
    var selectedDaySubject = BehaviorSubject<(weekday: Date.WeekDay, day: Int)?>(value: nil)
}
