//
//  AddTodoDayViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import Foundation
import RxSwift

class AddTodoDayViewModel {
    var days = BehaviorSubject<[String]>(value: ["월", "화", "수", "목", "금", "토", "일"])
}
