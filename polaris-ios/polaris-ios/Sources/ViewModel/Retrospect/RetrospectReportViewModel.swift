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
    
    let loadingSubject = PublishSubject<Bool>()
    let reportDateRelay: BehaviorRelay<PolarisDate> = {
        let currentDate = PolarisDate(
            year: Date.currentYear,
            month: Date.currentMonth,
            weekNo: Date.currentWeekNoOfMonth
        )
        return BehaviorRelay<PolarisDate>(value: currentDate)
    }()
    
    let retrospectReportRelay = BehaviorRelay<RetrospectModel?>(value: nil)
    let foundStarRelayBehaviorRelay: BehaviorRelay<RetrospectValueListModel> = {
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
    
    var reportDate: PolarisDate {
        self.reportDateRelay.value
    }
    
    init(repository: RetrospectRepository = RetrospectRepositoryImpl()) {
        self.repository = repository
        
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
            let date = self.reportDate
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
    
    func updateReportDate(date: PolarisDate) {
        self.reportDateRelay.accept(date)
    }
    
    private func bindDate() {
        self.reportDateRelay
            .withUnretained(self)
            .do(onNext: { owner, _ in owner.retrospectLoadingSubject.onNext(true) })
            .flatMapLatest({ owner, date in
                return owner.repository.fetchRetrospect(ofDate: date)
            })
            .do(onNext: { [weak self] _ in self?.retrospectLoadingSubject.onNext(false) })
            .bind(to: self.retrospectReportRelay)
            .disposed(by: self.disposeBag)
        
        self.reportDateRelay
            .withUnretained(self)
            .do(onNext: { owner, _ in owner.foundStarLoadingSubject.onNext(true) })
            .flatMapLatest({ owner, date in
                return owner.repository.fetchListValues(ofDate: date)
            })
            .do(onNext: { [weak self] _ in self?.foundStarLoadingSubject.onNext(false) })
            .bind(to: self.foundStarRelayBehaviorRelay)
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(self.retrospectLoadingSubject, self.foundStarLoadingSubject)
            .withUnretained(self)
            .subscribe(onNext: { owner, tuple in
                let retrospectLoading = tuple.0
                let foundStarLoading = tuple.1
        
                let loading = retrospectLoading || foundStarLoading
                owner.loadingSubject.onNext(loading)
            })
            .disposed(by: self.disposeBag)
    }
    
    private let foundStarLoadingSubject = PublishSubject<Bool>()
    private let retrospectLoadingSubject = PublishSubject<Bool>()
    
    private let repository: RetrospectRepository
    private let disposeBag = DisposeBag()
    
}
