//
//  WeekPickerViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/02/09.
//

import RxSwift
import RxRelay
import Foundation

final class WeekPickerViewModel {
            
    var loadingObservable: Observable<Bool> {
        self.loadingSubject.asObservable()
    }
    
    var reloadObservable: Observable<Void> {
        self.loadingSubject
            .filter({ $0 == false })
            .map { _ in }
            .asObservable()
    }
    
    var years: [Int] {
        self.lastWeekOfMonthModel.map { $0.year }
    }
    
    init(weekReposotiroy: WeekRepository = WeekRepositoryImpl()) {
        self.weekRepository = weekReposotiroy
    }
    
    func weekNo(ofYear year: Int, ofMonth month: Int) -> Int? {
        guard let monthModel = self.lastWeekOfMonthModel.first(where: { $0.year == year }) else { return nil }
        return monthModel.weekNo(ofMonth: month)
    }
    
    func occurViewAction(action: ViewAction) {
        switch action {
        case .requestWeekInformation:
            self.requestWeekInformation()
        case .pickerSelected(let date):
            self.updateSelectedDate(date: date)
        }
    }
    
    private func requestWeekInformation() {
        self.loadingSubject.onNext(true)
        
        self.weekRepository.fetchLastWeekOfMonth()
            .catchAndReturn([])
            .withUnretained(self)
            .subscribe(onNext: { owner, model in
                owner.lastWeekOfMonthModel = model
                owner.loadingSubject.onNext(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateSelectedDate(date: PolarisDate) {
        self.selectedDate = date
    }
    
    private(set) var selectedDate = PolarisDate(year: 2022, month: 12, weekNo: 4)
    private var lastWeekOfMonthModel = [LastWeekOfMonthDataModel]()
    
    private let loadingSubject = PublishSubject<Bool>()
    private let requestedSubject = PublishSubject<Void>()
    
    private let weekRepository: WeekRepository
    private let disposeBag = DisposeBag()
    
}

extension WeekPickerViewModel {
    
    enum ViewAction {
        case requestWeekInformation
        case pickerSelected(date: PolarisDate)
    }
    
}
