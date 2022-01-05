//
//  AddTodoDeleteJourneyTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/09/04.
//

import RxCocoa
import RxSwift
import UIKit

protocol AddTodoDeleteJourneyTableViewCellDelegate: AddTodoTableViewCellDelegate {
    func addTodoDeleteJourneyTableViewCellDidTapDelete(_ cell: AddTodoDeleteJourneyTableViewCell)
}

class AddTodoDeleteJourneyTableViewCell: AddTodoTableViewCell {
    
    override class var cellHeight: CGFloat {
        return (26 * 2) + 20
    }
    
    override var delegate: AddTodoTableViewCellDelegate? {
        didSet { self._delegate = self.delegate as? AddTodoDeleteJourneyTableViewCellDelegate }
    }
    
    weak var _delegate: AddTodoDeleteJourneyTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
    }
    
    private func bindButtons() {
        self.deleteButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self._delegate?.addTodoDeleteJourneyTableViewCellDidTapDelete(self)
            }).disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var deleteButton: UIButton!
    
}
