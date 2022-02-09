//
//  WeekPickerViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/02/09.
//

import RxSwift
import Foundation

final class WeekPickerViewModel {
    
    let loadingSubject = PublishSubject<Bool>()
    
    init(weekReposotiroy: WeekRepository = WeekRepositoryImpl()) {
        self.weekRepository = weekReposotiroy
    }
    
    func requestLastMonthOfWeek() {
        
    }
    
    private(set) var yearList: [Int] = [
        Date.currentYear - 2,
        Date.currentYear - 1,
        Date.currentYear,
        Date.currentYear + 1,
        Date.currentYear + 2
    ]
    
    private(set) var monthList: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    
    private let weekRepository: WeekRepository
    private let disposeBag = DisposeBag()
    
}
