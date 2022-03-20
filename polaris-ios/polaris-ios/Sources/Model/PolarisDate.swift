//
//  PolarisDate.swift
//  Polaris
//
//  Created by Dongmin on 2022/01/26.
//

import Foundation

struct PolarisDate: Equatable, Codable {
    let year: Int
    let month: Int
    let weekNo: Int
}

extension PolarisDate {
    
    var thisWeekDates: [Date] {
        var dates = WeekDay.allCases.compactMap { weekDay in
            DateComponents(
                calendar: .koreaISO8601,
                year: self.year,
                month: self.month,
                weekday: weekDay.rawValue,
                weekOfMonth: self.weekNo
            ).date?.normalizedDate
        }
        
        let sundayDate = dates.removeFirst()
        dates.append(sundayDate)
        return dates
    }
    
}
