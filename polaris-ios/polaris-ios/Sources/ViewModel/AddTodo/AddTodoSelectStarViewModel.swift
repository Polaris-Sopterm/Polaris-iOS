//
//  AddTodoSelectStarViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import Foundation
import RxSwift

class AddTodoSelectStarViewModel {
    lazy var starsSubject   = BehaviorSubject<[Journey]>(value: self.initJourneys())
    
    var selectedFlagSubject = PublishSubject<Journey>()
    var selectedStarsSet    = Set<Journey>()
    
    init() {
        _ = self.selectedFlagSubject
            .subscribe(onNext: { [weak self] selectedStar in
                guard let self = self else { return }
                defer { self.starsSubject.onNext(self.initJourneys()) }
                
                if self.selectedStarsSet.contains(selectedStar) { self.selectedStarsSet.remove(selectedStar); return }
                if self.selectedStarsSet.count >= self.selectedMaxCount { return }
                
                self.selectedStarsSet.insert(selectedStar)
            })
    }
    
    private func initJourneys() -> [Journey] {
        var journeys: [Journey] = []
        Journey.allCases.forEach { star in journeys.append(star) }
        return journeys
    }
    
    private let selectedMaxCount = 2
}
