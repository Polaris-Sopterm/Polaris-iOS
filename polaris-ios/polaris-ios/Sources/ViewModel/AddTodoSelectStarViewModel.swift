//
//  AddTodoSelectStarViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import Foundation
import RxSwift

class AddTodoSelectStarViewModel {
    lazy var starsSubject   = BehaviorSubject<[PolarisStar]>(value: self.initPolarisStars())
    
    var selectedFlagSubject = PublishSubject<PolarisStar>()
    var selectedStarsSet    = Set<PolarisStar>()
    
    init() {
        _ = self.selectedFlagSubject
            .subscribe(onNext: { [weak self] selectedStar in
                guard let self = self else { return }
                defer { self.starsSubject.onNext(self.initPolarisStars()) }
                
                if self.selectedStarsSet.contains(selectedStar) { self.selectedStarsSet.remove(selectedStar); return }
                if self.selectedStarsSet.count >= self.selectedMaxCount { return }
                
                self.selectedStarsSet.insert(selectedStar)
            })
    }
    
    private func initPolarisStars() -> [PolarisStar] {
        var stars: [PolarisStar] = []
        PolarisStar.allCases.forEach { star in stars.append(star) }
        return stars
    }
    
    private let selectedMaxCount = 2
}
