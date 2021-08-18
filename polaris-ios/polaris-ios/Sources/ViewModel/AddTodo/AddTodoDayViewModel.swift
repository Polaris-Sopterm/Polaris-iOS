//
//  AddTodoDayViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import Foundation
import RxSwift
import RxRelay

class AddTodoDayViewModel {
    
    let datesRelay        = BehaviorRelay<[Date]>(value: Date.datesIncludedThisWeek)
    let selectedDateSubject = BehaviorSubject<Date?>(value: nil)
    
}
