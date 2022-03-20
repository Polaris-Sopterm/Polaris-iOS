//
//  WeekDay.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/03/19.
//

import Foundation

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
