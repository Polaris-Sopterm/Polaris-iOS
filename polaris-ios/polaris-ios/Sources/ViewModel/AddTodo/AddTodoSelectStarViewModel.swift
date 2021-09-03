//
//  AddTodoSelectStarViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import Foundation
import RxSwift
import RxRelay

class AddTodoSelectStarViewModel {
    
    let journeysSubject  = BehaviorRelay<[Journey]>(value: Journey.allCases)
    var selectedStarsSet = Set<Journey>()
    
    func selectJourney(_ journey: Journey) {
        defer { self.journeysSubject.accept(Journey.allCases) }
        
        guard self.selectedStarsSet.contains(journey) == false else {
            self.selectedStarsSet.remove(journey)
            return
        }
        
        guard self.selectedStarsSet.count < self.selectedMaxCount else { return }
        self.selectedStarsSet.insert(journey)
    }
    
    private let selectedMaxCount = 2
}
