//
//  PolarisMakerViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/09/04.
//

import Foundation
import RxSwift
import RxRelay

final class PolarisMakerViewModel {
    
    let makersRelay        = BehaviorRelay<[PolarisMaker]>(value: PolarisMaker.allCases)
    let currentPageSubject = BehaviorSubject<Int>(value: 0)
    
    private let disposeBag = DisposeBag()
    
}
