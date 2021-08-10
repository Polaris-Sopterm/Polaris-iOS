//
//  OnboardingViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/09.
//

import Foundation
import RxSwift
import RxRelay

final class OnboardingViewModel {
    
    let onboardingLevelRelay = BehaviorRelay<[OnboardingVC.OnboardingLevel]>(value: OnboardingVC.OnboardingLevel.allCases)
    let currentPageRelay     = BehaviorRelay<Int>(value: 0)
    
    func updateCurrnetPage(_ level: OnboardingVC.OnboardingLevel) {
        self.currentPageRelay.accept(level.rawValue)
    }
    
}
