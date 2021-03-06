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
        Calendar.koreaISO8601.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    }
    
    /// 오늘의 날짜 - ex) 10, 11
    static var todayDay: Int {
        Calendar.koreaISO8601.component(.day, from: self.normalizedCurrent)
    }
    
    /// 오늘의 요일 - ex) 월, 화, 수, 목, 금, 토, 일
    static var todayWeekDay: String {
        let todayWeekDay  = Calendar.koreaISO8601.component(.weekday, from: self.normalizedCurrent)
        guard let weekDay = WeekDay(rawValue: todayWeekDay) else { return "" }
        return weekDay.korWeekday
    }
    
    /// 이번주 포함되는 날짜들: 월화수목금토일 순서 - ex) 19, 20, 21, 22, 23, 24, 25
    /// - 월 index : 0
    /// - 화 index : 1
    /// - 수 index : 2
    /// - 목 index : 3
    /// - 금 index : 4
    /// - 토 index : 5
    /// - 일 index : 6
    static var daysIncludedThisWeek: [Int] {
        let currentWeekDay = Calendar.koreaISO8601.component(.weekday, from: self.normalizedCurrent)
        
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
            guard let calculatedDate = Calendar.koreaISO8601.date(byAdding: .day, value: distance, to: self.normalizedCurrent) else { return }
            
            let calculatedDay = Calendar.koreaISO8601.component(.day, from: calculatedDate)
            week.append(calculatedDay)
        }
        return week
    }
    
    /// 이번주에 포함되는 Dates - 월, 화, 수, 목, 금, 토, 일 순서
    /// - 월 index : 0
    /// - 화 index : 1
    /// - 수 index : 2
    /// - 목 index : 3
    /// - 금 index : 4
    /// - 토 index : 5
    /// - 일 index : 6
    static var datesIncludedThisWeek: [Date] {
        self.datesIncludedInWeek(fromDate: .normalizedCurrent)
    }
    
    static var thursdayOfThisWeek: Date {
        Self.datesIncludedThisWeek[safe: 3] ?? Date.normalizedCurrent
    }
    
    static var currentWeekNoOfMonth: Int {
        Calendar.koreaISO8601.component(.weekOfMonth, from: Date.thursdayOfThisWeek)
    }
    
    static var currentMonth: Int {
        Calendar.koreaISO8601.component(.month, from: Date.thursdayOfThisWeek)
    }
    
    static var currentYear: Int {
        Calendar.koreaISO8601.component(.year, from: Date.thursdayOfThisWeek)
    }
    
    static var currentPolarisDate: PolarisDate {
        PolarisDate(year: Date.currentYear, month: Date.currentMonth, weekNo: Date.currentWeekNoOfMonth)
    }
    
    var normalizedDate: Date? {
        return Calendar.koreaISO8601.date(bySettingHour: 12, minute: 0, second: 0, of: self)
    }
    
    static func convertWeekNoToString(weekNo: Int) -> String? {
        let weekDict = [1: "첫째주", 2: "둘째주", 3: "셋째주", 4: "넷째주", 5: "다섯째주"]
        return weekDict[weekNo]
    }
    
    static func datesIncludedInWeek(fromDate date: Date) -> [Date] {
        let normalizedDate = date.normalizedDate ?? date
        let weekDay = Calendar.koreaISO8601.component(.weekday, from: normalizedDate)
        
        var datesIncludedWeek: [Date]      = []
        var distancesBetweenWeekDay: [Int] = []
        
        if weekDay == WeekDay.sunday.rawValue {
            distancesBetweenWeekDay = [-6, -5, -4, -3, -2, -1, 0] }
        else {
            for weekDayValue in WeekDay.monday.rawValue...WeekDay.saturday.rawValue {
                let tempDistanceBetweenWeekDay = weekDayValue - weekDay
                distancesBetweenWeekDay.append(tempDistanceBetweenWeekDay)
            }
            
            let sundayWeekDay = 8
            distancesBetweenWeekDay.append(sundayWeekDay - weekDay)
        }
        
        distancesBetweenWeekDay.forEach { distance in
            guard let calculatedDate = Calendar.koreaISO8601.date(byAdding: .day, value: distance, to: normalizedDate) else { return }
            datesIncludedWeek.append(calculatedDate)
        }
        
        return datesIncludedWeek
    }
    
    static func datesIncludedInWeek(fromPolarisDate date: PolarisDate) -> [Date] {
        let dateComponents = DateComponents(
            calendar: .koreaISO8601,
            timeZone: .korea,
            year: date.year,
            month: date.month,
            hour: 12,
            minute: 0,
            second: 0,
            weekday: WeekDay.thursday.rawValue,
            weekOfMonth: date.weekNo
        )
        
        let dateFromComponent = Calendar.koreaISO8601.date(from: dateComponents) ?? .normalizedCurrent
        return Self.datesIncludedInWeek(fromDate: dateFromComponent)
    }
    
    func convertToString(using format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

}
