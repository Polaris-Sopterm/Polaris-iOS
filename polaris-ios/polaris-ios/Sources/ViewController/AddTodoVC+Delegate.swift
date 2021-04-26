//
//  AddTodoVC+Delegate.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import Foundation

extension AddTodoVC: AddTodoTableViewCellDelegate {}

extension AddTodoVC: AddTodoTextTableViewCellDelegate {
    func addTodoTextTableViewCell(_ tableViewCell: AddTodoTextTableViewCell, didChangeText text: String) {
        self.viewModel.addTextSubject.onNext(text)
    }
}

extension AddTodoVC: AddTodoDayTableViewCellDelegate {
    func addTodoDayTableViewCell(_ addTodoDayTableViewCell: AddTodoDayTableViewCell, didSelectDay day: Int, didSelectWeekday weekday: Date.WeekDay) {
        self.viewModel.selectDaySubject.onNext((weekday, day))
    }
}

extension AddTodoVC: AddTodoFixOnTopTableViewCellDelegate {
    func addTodoFixOnTopTableViewCell(_ addTodoFixOnTopTableViewCell: AddTodoFixOnTopTableViewCell, shouldFixed isFixed: Bool) {
        self.viewModel.fixOnTopSubject.onNext(isFixed)
    }
}

extension AddTodoVC: AddTodoDropdownTableViewCellDelegate {
    func addTodoDropdownTableViewCell(_ addTodoDropdownTableViewCell: AddTodoDropdownTableViewCell, didSelectedMenu menu: String) {
        self.viewModel.dropdownSubject.onNext(menu)
    }
}

extension AddTodoVC: AddTodoSelectStarTableViewCellDelegate {
    func addTodoSelectStarTableViewCell(_ addTodoSelectStarTableViewCell: AddTodoSelectStarTableViewCell, didSelectedStars stars: Set<PolarisStar>) {
        self.viewModel.selectStarSubject.onNext(stars)
    }
}
