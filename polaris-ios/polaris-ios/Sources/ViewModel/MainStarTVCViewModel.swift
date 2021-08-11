//
//  MainStarTVCViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import Foundation
import RxSwift
import RxCocoa

class MainStarTVCViewModel {
    var starListRelay: BehaviorRelay<[MainStarCVCViewModel]> = BehaviorRelay(value: [])
}
