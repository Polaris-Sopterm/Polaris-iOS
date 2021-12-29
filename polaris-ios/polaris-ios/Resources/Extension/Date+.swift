//
//  Date+.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import Foundation

extension Date {
    /// 오늘의 Date를 12시로 표준화
    static var normalizedCurrent: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    }
    
    /// 오늘의 날짜 - ex) 10, 11
    static var todayDay: Int {
        return Calendar.current.component(.day, from: self.normalizedCurrent)
    }
    
    /// 오늘의 요일 - ex) 월, 화, 수, 목, 금, 토, 일
    static var todayWeekDay: String {
        let todayWeekDay  = Calendar.current.component(.weekday, from: self.normalizedCurrent)
        guard let weekDay = WeekDay(rawValue: todayWeekDay) else { return "" }
        return weekDay.korWeekday
    }
    
    /// 이번주 포함되는 날짜들: 월화수목금토일 순서 - ex) 19, 20, 21, 22, 23, 24, 25
    static var daysIncludedThisWeek: [Int] {
        let currentWeekDay = Calendar.current.component(.weekday, from: self.normalizedCurrent)
        
        var week: [Int]                    = []
        var distancesBetweenWeekDay: [Int] = []
        
        if currentWeekDay == WeekDay.sunday.rawValue {
            distancesBetweenWeekDay = [-6, -5, -4, -3, -2, -1, 0] }
        else {
            for weekDay in WeekDay.monday.rawValue...WeekDay.saturday.rawValue {
                let tempDistanceBetweenWeekDay = weekDay - currentWeekDay
                distancesBetweenWeekDay.append(tempDistanceBetweenWeekDay)
            }
            
            let sundayWeekDay = 8
            distancesBetweenWeekDay.append(sundayWeekDay - currentWeekDay)
        }
        
        distancesBetweenWeekDay.forEach { distance in
            guard let calculatedDate = Calendar.current.date(byAdding: .day, value: distance, to: self.normalizedCurrent) else { return }
            
            let calculatedDay = Calendar.current.component(.day, from: calculatedDate)
            week.append(calculatedDay)
        }
        return week
    }
    
    /// 이번주에 포함되는 Dates - 월, 화, 수, 목, 금, 토, 일 순서
    static var datesIncludedThisWeek: [Date] {
        let currentWeekDay = Calendar.current.component(.weekday, from: self.normalizedCurrent)
        
        var datesIncludedWeek: [Date]      = []
        var distancesBetweenWeekDay: [Int] = []
        
        if currentWeekDay == WeekDay.sunday.rawValue {
            distancesBetweenWeekDay = [-6, -5, -4, -3, -2, -1, 0] }
        else {
            for weekDay in WeekDay.monday.rawValue...WeekDay.saturday.rawValue {
                let tempDistanceBetweenWeekDay = weekDay - currentWeekDay
                distancesBetweenWeekDay.append(tempDistanceBetweenWeekDay)
            }
            
            let sundayWeekDay = 8
            distancesBetweenWeekDay.append(sundayWeekDay - currentWeekDay)
        }
        
        distancesBetweenWeekDay.forEach { distance in
            guard let calculatedDate = Calendar.current.date(byAdding: .day, value: distance, to: self.normalizedCurrent) else { return }
            datesIncludedWeek.append(calculatedDate)
        }
        
        return datesIncludedWeek
    }
    
    static var daysThisWeek: [Date] {
        let currentWeekDay  = Calendar.current.component(.weekday, from: self.normalizedCurrent)
        
        var thisWeekDates: [Date] = []
        var distancesBetweenWeekDay: [Int] = []
        
        if currentWeekDay == WeekDay.sunday.rawValue {
            distancesBetweenWeekDay = [-6, -5, -4, -3, -2, -1, 0] }
        else {
            for weekDay in WeekDay.monday.rawValue...WeekDay.saturday.rawValue {
                let tempDistanceBetweenWeekDay = weekDay - currentWeekDay
                distancesBetweenWeekDay.append(tempDistanceBetweenWeekDay)
            }
            
            let sundayWeekDay = 8
            distancesBetweenWeekDay.append(sundayWeekDay - currentWeekDay)
        }
        
        distancesBetweenWeekDay.forEach { distance in
            guard let calculatedDate = Calendar.current.date(byAdding: .day, value: distance, to: self.normalizedCurrent) else { return }
            thisWeekDates.append(calculatedDate)
        }
        return thisWeekDates
    }
    
    var normalizedDate: Date? {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)
    }
    
    func convertToString(using format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    static var currentWeekNoOfMonth: Int {
        var weekNo = Calendar.current.component(.weekOfMonth, from: self.normalizedCurrent) - 1
        if Calendar.current.dateComponents([.calendar, .year,.month], from: normalizedCurrent).weekdayOrdinal == 2 {
            weekNo += 1
        }
        return weekNo
    }
    
    static var currentMonth: Int {
        return Calendar.current.component(.month, from: self.normalizedCurrent)
    }
    
    static var currentYear: Int {
        return Calendar.current.component(.year, from: self.normalizedCurrent)
    }
    
    static func numberOfMondaysInMonth(_ month: Int, forYear year: Int) -> Int? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // 2 == Monday
        // First monday in month:
        var comps = DateComponents(year: year, month: month,
                                   weekday: calendar.firstWeekday, weekdayOrdinal: 1)
        guard let first = calendar.date(from: comps)  else {
            return nil
        }
        // Last monday in month:
        comps.weekdayOrdinal = -1
        guard let last = calendar.date(from: comps)  else {
            return nil
        }
        // Difference in weeks:
        let weeks = calendar.dateComponents([.weekOfMonth], from: first, to: last)
        return weeks.weekOfMonth! + 1
    }

}

extension Date {
    enum WeekDay: Int, CaseIterable {
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
}
