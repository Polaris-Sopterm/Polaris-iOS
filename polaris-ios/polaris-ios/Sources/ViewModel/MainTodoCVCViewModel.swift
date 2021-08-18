//
//  MainTodoCVCViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/28.
//

import Foundation
import RxSwift
import RxCocoa

struct MainTodoCVCViewModel {
    var todoListRelay: BehaviorRelay<[MainTodoTVCViewModel]> = BehaviorRelay(value: [])
    var journeyNameRelay: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    var valueRelay: BehaviorRelay<[String]> = BehaviorRelay(value: [])
}
