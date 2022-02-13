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
        self.lastWeekOfMonthModel
            .first(where: { $0.year == year })?
            .weekNo(ofMonth: month)
    }
    
    func occurViewAction(action: ViewAction) {
        switch action {
        case .viewDidLoad:
            self.requestInitialData()
        case .pickerSelected(let date):
            self.updateSelectedDate(date: date)
        }
    }
    
    private func requestInitialData() {
        self.loadingSubject.onNext(true)
        
        if self.selectedDate == nil {
            Observable.zip(self.requestWeekInformation(), self.requestCurrentWeekNo())
                .subscribe(onNext: { [weak self] weeksModel, currentWeekNo in
                    let selectedDate = PolarisDate(year: Date.currentYear, month: Date.currentMonth, weekNo: currentWeekNo)
                    self?.selectedDate = selectedDate
                    self?.lastWeekOfMonthModel = weeksModel
                    self?.loadingSubject.onNext(false)
                })
                .disposed(by: self.disposeBag)
        } else {
            self.requestWeekInformation()
                .subscribe(onNext: { [weak self] weeksModel in
                    self?.lastWeekOfMonthModel = weeksModel
                    self?.loadingSubject.onNext(false)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    private func requestWeekInformation() -> Observable<[LastWeekOfMonthDataModel]> {
        self.weekRepository.fetchLastWeekOfMonth()
            .catchAndReturn([])
    }
    
    private func requestCurrentWeekNo() -> Observable<Int> {
        self.weekRepository.fetchWeekNo(ofDate: Date.normalizedCurrent)
            .catchAndReturn(1)
    }
    
    private func updateSelectedDate(date: PolarisDate) {
        self.selectedDate = date
    }
    
    private(set) var selectedDate: PolarisDate?
    private var lastWeekOfMonthModel = [LastWeekOfMonthDataModel]()
    
    private let loadingSubject = PublishSubject<Bool>()
    private let requestedSubject = PublishSubject<Void>()
    
    private let weekRepository: WeekRepository
    private let disposeBag = DisposeBag()
    
}

extension WeekPickerViewModel {
    
    enum ViewAction {
        case viewDidLoad
        case pickerSelected(date: PolarisDate)
    }
    
}
