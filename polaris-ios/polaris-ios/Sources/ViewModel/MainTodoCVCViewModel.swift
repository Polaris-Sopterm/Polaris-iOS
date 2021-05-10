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
    var starName: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    
}
