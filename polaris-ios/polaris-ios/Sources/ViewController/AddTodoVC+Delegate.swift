//
//  AddTodoVC+Delegate.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import Foundation

extension AddTodoVC: AddTodoTableViewCellDelegate {}

extension AddTodoVC: AddTodoTextTableViewCellDelegate {
    func addTodoTextTableViewCell(_ tableViewCell: AddTodoTextTableViewCell, didChangeText: String) {
        print(didChangeText)
    }
}

extension AddTodoVC: AddTodoDayTableViewCellDelegate {
    func addTodoDayTableViewCell(_ addTodoDayTableViewCell: AddTodoDayTableViewCell, didSelectDay: Int, didSelectWeekday: Date.WeekDay) {
        print(didSelectDay, didSelectWeekday)
    }
}

