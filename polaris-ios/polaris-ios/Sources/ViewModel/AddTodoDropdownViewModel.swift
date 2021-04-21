//
//  AddTodoDropdownViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/19.
//

import Foundation
import RxSwift

class AddTodoDropdownViewModel {
    var isExpanded      = BehaviorSubject<Bool>(value: false)
    var selectedMenu    = BehaviorSubject<String?>(value: nil)
    var menus           = BehaviorSubject<[String]>(value: ["폴라리스 그리기", "포트폴리오 만들기", "등등", "이것도 저것도", "만들어 보자", "너도", "등등", "더있나"])
}
