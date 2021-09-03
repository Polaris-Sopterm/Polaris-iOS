//
//  AddTodoSelectStarViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import Foundation
import RxSwift

class AddTodoSelectStarViewModel {
    let jounreysSubject     = BehaviorSubject<[Journey]>(value: Journey.allCases)
    let selectedFlagSubject = PublishSubject<Journey>()
    var selectedStarsSet    = Set<Journey>()
    
    init() {
        _ = self.selectedFlagSubject
            .subscribe(onNext: { [weak self] selectedStar in
                guard let self = self                                       else { return }
                guard self.selectedStarsSet.contains(selectedStar) == false else {
                    self.selectedStarsSet.remove(selectedStar)
                    return
                }
                
                guard self.selectedStarsSet.count < self.selectedMaxCount else { return }
                self.selectedStarsSet.insert(selectedStar)
            })
    }
    
    func selectJourney(_ selectedJourney: Journey) {
        guard self.selectedStarsSet.contains(selectedJourney) == false else {
            self.selectedStarsSet.remove(selectedJourney)
            return
        }
        guard self.selectedStarsSet.count <= self.selectedMaxCount else { return }
        self.selectedStarsSet.insert(selectedJourney)
    }
    
    private let selectedMaxCount = 2
}
