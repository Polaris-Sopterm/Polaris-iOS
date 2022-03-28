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
    
    init(
        retrospectRepository: RetrospectRepository = RetrospectRepositoryImpl(),
        weekRepository: WeekRepository = WeekRepositoryImpl()
    ) {
        self.retrospectRepository = retrospectRepository
        self.weekRepository = weekRepository
        
        self.observe(viewEvent: self.viewEventRelay)
    }
    
    func occur(viewEvent: ViewEvent) {
        self.viewEventRelay.accept(viewEvent)
    }
    
    func sortRetrospectValueModel(model: RetrospectValueListModel) -> [(String, Int)] {
        guard let encodeModel = try? JSONEncoder().encode(model) else { return [] }
        
        let dic = try? JSONSerialization.jsonObject(with: encodeModel, options: .fragmentsAllowed) as? [String: Int]
        guard let decodeDic = dic else { return [] }
        
        return decodeDic.sorted(by: { first, second in
            return first.value < second.value
        })
    }
    
    private func observe(viewEvent: PublishRelay<ViewEvent>) {
        viewEvent
            .withUnretained(self)
            .subscribe(onNext: { owner, event in
                owner.handleViewEvent(event)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .viewDidLoad:
            self.requestRetrospectValues()
            self.requestLastWeekRetrospect()
            
        case .notifyUpdateTodo(let scene):
            self.reloadRetrospectValueIfNeeded(asScene: scene)
        }
    }
    
    private func requestRetrospectValues() {
        self.retrospectRepository.fetchListValues(ofDate: nil)
            .bind(to: self.journeyValueRelay)
            .disposed(by: self.disposeBag)
    }
    
    private func requestLastWeekRetrospect() {
        let date = Calendar.koreaISO8601.date(byAdding: .weekOfMonth, value: -1, to: Date.normalizedCurrent)
        guard let lastWeekDate = date else { return }
        
        let polarisDate = Calendar.koreaISO8601.polarisDate(from: lastWeekDate)
        self.retrospectRepository.fetchRetrospect(ofDate: polarisDate)
            .withUnretained(self)
            .subscribe(onNext: { owner, retrospect in
                if retrospect != nil {
                    owner.isExistLastWeekRetrospectRelay.accept(true)
                } else {
                    owner.isExistLastWeekRetrospectRelay.accept(false)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func reloadRetrospectValueIfNeeded(asScene scene: String) {
        guard scene != MainSceneCellType.retrospect.sceneIdentifier else { return }
        self.requestRetrospectValues()
        self.requestLastWeekRetrospect()
    }
    
    private let retrospectSubject = PublishSubject<RetrospectModel?>()
    private let disposeBag = DisposeBag()
    
    private let weekRepository: WeekRepository
    private let retrospectRepository: RetrospectRepository
    
    private let viewEventRelay = PublishRelay<ViewEvent>()

}

extension RetrospectViewModel {
    
    enum ViewEvent {
        case viewDidLoad
        case notifyUpdateTodo(scene: String)
    }
    
}
