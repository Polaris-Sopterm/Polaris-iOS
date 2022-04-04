//
//  MainSceneDateSelector.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/03/19.
//

import Foundation
import RxRelay
import RxSwift

final class MainSceneDateSelector {
    
    static let shared = MainSceneDateSelector()
    
    var selectedDate: PolarisDate {
        self.selectedDateRelay.value
    }
    
    var selectedDateObservable: Observable<PolarisDate> {
        self.selectedDateRelay.asObservable()
    }
    
    func updateDate(_ date: PolarisDate) {
        self.selectedDateRelay.accept(date)
    }
    
    private init() {}
    
    private let disposeBag = DisposeBag()
    private let selectedDateRelay: BehaviorRelay<PolarisDate> = {
        return BehaviorRelay<PolarisDate>(value: Date.currentPolarisDate)
    }()
    
}
