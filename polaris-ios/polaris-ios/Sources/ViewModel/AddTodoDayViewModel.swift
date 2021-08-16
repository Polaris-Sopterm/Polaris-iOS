//
//  AddTodoDayViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import Foundation
import RxSwift

class AddTodoDayViewModel {
    
    let datesSubject        = BehaviorSubject<[Date]>(value: Date.datesIncludedThisWeek)
    let selectedDateSubject = BehaviorSubject<Date?>(value: nil)
    
}
