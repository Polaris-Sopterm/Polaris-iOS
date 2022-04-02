//
//  RetrospectViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/05.
//

import RxRelay
import RxSwift
import Foundation

enum RetrospectReportCategory: Int, CaseIterable {
    case foundStar
    case closeStar
    case farStar
    case emotion
    case emotionReason
    
    var cellType: RetrospectReportCell.Type {
        switch self {
        case .foundStar:     return RetrospectFoundStarTableViewCell.self
        case .closeStar:     return RetrospectCloseStarTableViewCell.self
        case .farStar:       return RetrospectFarStarTableViewCell.self
        case .emotion:       return RetrospectEmotionTableViewCell.self
        case .emotionReason: return RetrospectEmotionReasonTableViewCell.self
        }
    }
}

class RetrospectReportViewModel {
    
    var loadingObservable: Observable<Bool> {
        self.loadingSubject.asObservable()
    }
    
    var reportObservable: Observable<RetrospectModel?> {
        self.retrospectReportRelay.asObservable()
    }
    
    var foundStarObservable: Observable<RetrospectValueListModel> {
        self.foundStarRelayBehaviorRelay.asObservable()
    }
    
    var reportDateObservable: Observable<PolarisDate> {
        self.reportDateRelay
            .compactMap { $0 }
            .asObservable()
    }
    
    var reportDate: PolarisDate? {
        self.reportDateRelay.value
    }
    
    init(retrospectRepository: RetrospectRepository = RetrospectRepositoryImpl()) {
        self.retrospectRepository = retrospectRepository
        
        self.bindDate()
    }
    
    func numberOfRows() -> Int {
        if self.foundStarRelayBehaviorRelay.value.isAchieveJourneyAtLeastOne {
            return self.retrospectReportRelay.value != nil ? RetrospectReportCategory.allCases.count : 1
        } else {
            return 0
        }
    }
    
    func presentable(cellForCategoryAt category: RetrospectReportCategory) -> RetrospectReportPresentable? {
        switch category {
        case .foundStar:
            let foundStar = self.foundStarRelayBehaviorRelay.value
            guard let date = self.reportDate else { return nil }
            return RetrospectReportPresentableFormatter.formatToFoundStarViewModel(fromModel: foundStar, date: date)
        case .closeStar:
            guard let retrospectModel = self.retrospectReportRelay.value else { return nil }
            return RetrospectReportPresentableFormatter.formatToCloseStarViewModel(fromModel: retrospectModel)
        case .farStar:
            guard let retrospectModel = self.retrospectReportRelay.value else { return nil }
            return RetrospectReportPresentableFormatter.formatToFarStarViewModel(fromModel: retrospectModel)
        case .emotion:
            guard let retrospectModel = self.retrospectReportRelay.value else { return nil }
            return RetrospectReportPresentableFormatter.formatToEmoticonViewModel(fromModel: retrospectModel)
        case .emotionReason:
            guard let retrospectModel = self.retrospectReportRelay.value else { return nil }
            return RetrospectReportPresentableFormatter.formatToEmoticonReasonViewModel(fromModel: retrospectModel)
        }
    }
    
    func occurViewAction(action: ViewAction) {
        switch action {
        case .weekPickerSelected(let date):
            self.updateReportDate(date: date)
        }
    }
    
    private func updateReportDate(date: PolarisDate) {
        self.reportDateRelay.accept(date)
    }
    
    private func bindDate() {
        let retrospectReportObservable = self.reportDateRelay
            .compactMap { $0 }
            .withUnretained(self)
            .do(onNext: { owner, _ in owner.loadingSubject.onNext(true) })
            .flatMapLatest({ owner, date in
                owner.retrospectRepository.fetchRetrospect(ofDate: date)
            })
        
        let foundStarObservable = self.reportDateRelay
            .compactMap { $0 }
            .withUnretained(self)
            .do(onNext: { owner, _ in owner.loadingSubject.onNext(true) })
            .flatMapLatest({ owner, date in
                owner.retrospectRepository.fetchListValues(ofDate: date)
            })
        
        Observable.zip(retrospectReportObservable, foundStarObservable)
            .withUnretained(self)
            .subscribe(onNext: { owner, tuple in
                let retrospectModel = tuple.0
                let foundStarModel = tuple.1
                
                owner.retrospectReportRelay.accept(retrospectModel)
                owner.foundStarRelayBehaviorRelay.accept(foundStarModel)
                owner.loadingSubject.onNext(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    private let loadingSubject = PublishSubject<Bool>()
    private let reportDateRelay: BehaviorRelay<PolarisDate> = {
        let currentYear = Date.currentYear
        let currentMonth = Date.currentMonth
        let currentWeekNo = Date.currentWeekNoOfMonth
        let date = PolarisDate(year: currentYear, month: currentMonth, weekNo: currentWeekNo)
        return BehaviorRelay<PolarisDate>(value: date)
    }()
    private let retrospectReportRelay = BehaviorRelay<RetrospectModel?>(value: nil)
    private let foundStarRelayBehaviorRelay: BehaviorRelay<RetrospectValueListModel> = {
        let model = RetrospectValueListModel(
            happiness: 0,
            control: 0,
            thanks: 0,
            rest: 0,
            growth: 0,
            change: 0,
            health: 0,
            overcome: 0,
            challenge: 0
        )
        return BehaviorRelay<RetrospectValueListModel>(value: model)
    }()
    
    private let retrospectRepository: RetrospectRepository
    private let disposeBag = DisposeBag()
    
}

extension RetrospectReportViewModel {
    
    enum ViewAction {
        case weekPickerSelected(date: PolarisDate)
    }
    
}
