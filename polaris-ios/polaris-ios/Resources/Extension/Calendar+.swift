//
//  Calendar+.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/03/19.
//

import Foundation

extension Calendar {
    
    static let koreaISO8601: Calendar = {
        var isoCalendar = Calendar(identifier: .iso8601)
        isoCalendar.locale = Locale(identifier: "ko_KR")
        isoCalendar.timeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent
        return isoCalendar
    }()
    
    func polarisDate(from date: Date) -> PolarisDate {
        let components = self.dateComponents([.year, .month, .weekOfMonth], from: date)
        return PolarisDate(
            year: components.year ?? Date.currentYear,
            month: components.month ?? Date.currentMonth,
            weekNo: components.weekOfMonth ?? Date.currentWeekNoOfMonth
        )
    }
    
}
