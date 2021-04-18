//
//  AddTodoViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import Foundation
import RxSwift

class AddTodoViewModel {
    var addListTypes = BehaviorSubject<[AddTodoTableViewCellProtocol.Type]>(value: [])
}
