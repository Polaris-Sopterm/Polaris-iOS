//
//  RetrospectViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/26.
//

import Foundation
import RxRelay
import RxSwift

final class RetrospectViewModel {
    
    let journeyValueRelay: BehaviorRelay<RetrospectValueListModel> = {
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
    
    let isExistLastWeekRetrospectRelay = BehaviorRelay<Bool>(value: false)
    
    init(retrospectRepository: RetrospectRepository = RetrospectRepositoryImpl()) {
        self.retrospectRepository = retrospectRepository
    }
    
    func requestRetrospectValues() {
        // FIXME: - 이전주의 날짜로 받아올 수 있게 수정해야 됌
        let year = Date.currentYear
        let month = Date.currentMonth
        let weekNo = Date.currentWeekNoOfMonth
        
        let date = PolarisDate(year: year, month: month, weekNo: weekNo)
        self.retrospectRepository.fetchListValues(ofDate: date)
            .bind(to: self.journeyValueRelay)
            .disposed(by: self.disposeBag)
    }
    
    func requestLastWeekRetrospect() {
        let year = Date.currentYear
        let month = Date.currentMonth
        let weekNo = Date.currentWeekNoOfMonth
        
        let date = PolarisDate(year: year, month: month, weekNo: weekNo)
        self.retrospectRepository.fetchRetrospect(ofDate: date)
            .subscribe(onNext: { _ in
                self.isExistLastWeekRetrospectRelay.accept(true)
            }, onError: { error in
                if let polarisError = error as? PolarisErrorModel.PolarisError {
                    self.isExistLastWeekRetrospectRelay.accept(false)
                } else {
                    // TODO: - 네트워크 에러에 따른 처리 필요(임시로 false accept)
                    self.isExistLastWeekRetrospectRelay.accept(false)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func sortRetrospectValueModel(model: RetrospectValueListModel) -> [(String, Int)] {
        guard let encodeModel = try? JSONEncoder().encode(model) else { return [] }
        
        let dic = try? JSONSerialization.jsonObject(with: encodeModel, options: .fragmentsAllowed) as? [String: Int]
        guard let decodeDic = dic else { return [] }
        
        return decodeDic.sorted(by: { first, second in
            return first.value < second.value
        })
    }
    
    private let retrospectSubject = PublishSubject<RetrospectModel?>()
    private let disposeBag = DisposeBag()
    
    private let retrospectRepository: RetrospectRepository

}
