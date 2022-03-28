//
//  AddTodoVC+Delegate.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import UIKit

extension AddTodoVC: AddTodoTableViewCellDelegate {}

extension AddTodoVC: AddTodoTextTableViewCellDelegate {
    func addTodoTextTableViewCell(_ tableViewCell: AddTodoTextTableViewCell, didChangeText text: String) {
        self.viewModel.addTextRelay.accept(text)
    }
}

extension AddTodoVC: AddTodoDayTableViewCellDelegate {
    func addTodoDayTableViewCell(_ addTodoDayTableViewCell: AddTodoDayTableViewCell, didSelectDate date: Date) {
        self.viewModel.selectDateRelay.accept(date)
    }
}

extension AddTodoVC: AddTodoFixOnTopTableViewCellDelegate {
    func addTodoFixOnTopTableViewCell(_ addTodoFixOnTopTableViewCell: AddTodoFixOnTopTableViewCell, shouldFixed isFixed: Bool) {
        self.viewModel.fixOnTopRelay.accept(isFixed)
    }
}

extension AddTodoVC: AddTodoDropdownTableViewCellDelegate {
    func addTodoDropdownTableViewCell(_ addTodoDropdownTableViewCell: AddTodoDropdownTableViewCell, didSelectedJourney journey: JourneyTitleModel) {
        self.viewModel.dropdownRelay.accept(journey)
    }
}

extension AddTodoVC: AddTodoSelectStarTableViewCellDelegate {
    func addTodoSelectStarTableViewCell(_ addTodoSelectStarTableViewCell: AddTodoSelectStarTableViewCell, didSelectedStars stars: Set<Journey>) {
        self.viewModel.selectJourneyRelay.accept(stars)
    }
}

extension AddTodoVC: AddTodoDeleteJourneyTableViewCellDelegate {
    func addTodoDeleteJourneyTableViewCellDidTapDelete(_ cell: AddTodoDeleteJourneyTableViewCell) {
        guard let popupView: PolarisPopupView = UIView.fromNib() else { return }
        popupView.configure(
            title: "이 여정을 삭제할까요?",
            subTitle: "한 번 삭제한 여정은 복구되지 않아요.",
            confirmTitle: "삭제하기",
            confirmHandler: { [weak self] in
                self?.viewModel.occur(viewEvent: .didTapDeleteJourney)
            },
            cancelHandler: nil
        )
        popupView.show(in: self.view)
    }
}
