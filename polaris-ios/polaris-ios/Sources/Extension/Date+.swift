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
        return Calendar.current.component(.day, from: normalizedCurrent)
    }
    
    /// 오늘의 요일 - ex) 월, 화, 수, 목, 금, 토, 일
    static var todayWeekDay: String {
        let todayWeekDay  = Calendar.current.component(.weekday, from: normalizedCurrent)
        guard let weekDay = WeekDay(rawValue: todayWeekDay) else { return "" }
        return weekDay.korWeekday
    }
    
    /// 이번주 포함되는 날짜들: 월화수목금토일 순서 - ex) 19, 20, 21, 22, 23, 24, 25
    static var daysIncludedThisWeek: [Int] {
        let currentWeekDay  = Calendar.current.component(.weekday, from: normalizedCurrent)
        
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
            guard let calculatedDate = Calendar.current.date(byAdding: .day, value: distance, to: normalizedCurrent) else { return }
            
            let calculatedDay = Calendar.current.component(.day, from: calculatedDate)
            week.append(calculatedDay)
        }
        return week
    }
    
    static var daysThisWeek: [Date] {
        let currentWeekDay  = Calendar.current.component(.weekday, from: normalizedCurrent)
        
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
            guard let calculatedDate = Calendar.current.date(byAdding: .day, value: distance, to: normalizedCurrent) else { return }
            thisWeekDates.append(calculatedDate)
        }
        return thisWeekDates
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
