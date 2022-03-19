//
//  MainSceneDateSelector.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/03/19.
//

import Foundation
import RxRelay
import RxSwift

final class MainSceneDateSelector {
    
    static let shared = MainSceneDateSelector()
    
    var selectedDate: PolarisDate? {
        self.selectedDateRelay.value
    }
    
    var selectedDateObservable: Observable<PolarisDate?> {
        self.selectedDateRelay.asObservable()
    }
    
    init(weekRepository: WeekRepository = WeekRepositoryImpl()) {
        self.weekRepository = weekRepository
        self.requestCurrentDate()
    }
    
    func updateDate(_ date: PolarisDate) {
        self.selectedDateRelay.accept(date)
    }
    
    private func requestCurrentDate() {
        self.weekRepository.fetchWeekNo(ofDate: Date.normalizedCurrent)
            .withUnretained(self)
            .subscribe(onNext: { owner, weekModel in
                let date = PolarisDate(year: weekModel.year, month: weekModel.month, weekNo: weekModel.weekNo)
                owner.selectedDateRelay.accept(date)
            })
            .disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    private let weekRepository: WeekRepository
    
    private let selectedDateRelay = BehaviorRelay<PolarisDate?>(value: nil)
    
}
