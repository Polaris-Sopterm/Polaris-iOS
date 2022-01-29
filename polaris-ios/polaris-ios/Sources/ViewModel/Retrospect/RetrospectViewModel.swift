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
    
    init(repository: RetrospectRepository = RetrospectRepositoryImpl()) {
        self.repository = repository
    }
    
    func requestRetrospectValues() {
        let year = Date.currentYear
        let month = Date.currentMonth
        let weekNo = Date.currentWeekNoOfMonth
        
        let date = PolarisDate(year: year, month: month, weekNo: weekNo)
        self.repository.fetchListValues(ofDate: date)
            .withUnretained(self)
            .subscribe(onNext: { owner, values in
                owner.journeyValueRelay.accept(values)
            }).disposed(by: self.disposeBag)
    }
    
    func sortRetrospectValueModel(model: RetrospectValueListModel) -> [(String, Int)] {
        guard let encodeModel = try? JSONEncoder().encode(model) else { return [] }
        
        let dic = try? JSONSerialization.jsonObject(with: encodeModel, options: .fragmentsAllowed) as? [String: Int]
        guard let decodeDic = dic else { return [] }
        
        return decodeDic.sorted(by: { first, second in
            return first.value < second.value
        })
    }
    
    private let repository: RetrospectRepository
    private let disposeBag = DisposeBag()

}
