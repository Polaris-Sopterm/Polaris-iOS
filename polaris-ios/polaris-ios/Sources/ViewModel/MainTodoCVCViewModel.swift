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
    let journeyTitle: String
    let journeyValues: [Journey]
    let todoListRelay: BehaviorRelay<[MainTodoTVCViewModel]>
}
