//
//  Date+.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import Foundation

extension Date {
    enum WeekDay: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
        
        var korWeekday: String {
            switch self {
            case .sunday:       return "일"
            case .monday:       return "월"
            case .tuesday:      return "화"
            case .wednesday:    return "수"
            case .thursday:     return "목"
            case .friday:       return "금"
            case .saturday:     return "토"
            }
        }
    }
    
    static var todayDay: Int {
        return Calendar.current.component(.day, from: Date())
    }
    
    static var todayWeekDay: String {
        let todayWeekDay  = Calendar.current.component(.weekday, from: Date())
        guard let weekDay = WeekDay(rawValue: todayWeekDay) else { return "" }
        return weekDay.korWeekday
    }
}
