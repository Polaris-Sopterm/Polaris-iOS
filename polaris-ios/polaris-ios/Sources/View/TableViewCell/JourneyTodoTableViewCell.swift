//
//  JourneyTodoTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/18.
//

import RxCocoa
import RxSwift
import UIKit

protocol JourneyTodoTableViewDelegate: TodoCategoryCellDelegate {
    func journeyTodoTableViewCell(_ journeyTodoTableViewCell: JourneyTodoTableViewCell, didTapCheck todo: String)
}

class JourneyTodoTableViewCell: TodoCategoryCell {
    
    override var delegate: TodoCategoryCellDelegate? {
        didSet {
            self._delegate = delegate as? JourneyTodoTableViewDelegate
        }
    }
    
    weak var _delegate: JourneyTodoTableViewDelegate?
    
    override static var cellHeight: CGFloat { return 63 * self.screenRatio }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
    }
    
    override func configure(_ todoModel: TodoModelProtocol) {
        guard let journeyTodoModel = todoModel as? WeekTodo else { return }
        
        self.todoLabel.text          = journeyTodoModel.title
        self.dayLabel.text           = journeyTodoModel.date
        self.fixedImageView.isHidden = journeyTodoModel.isTop == false
        
        self.updateUI(as: journeyTodoModel.isDone)
    }
    
    func updateUI(as checkState: String?) {
        self.todoLabel.textColor = checkState != nil ? .inactiveTextPurple : .maintext
        self.dayLabel.textColor  = checkState != nil ? .inactiveTextPurple : .maintext
        self.checkButton.setImage(checkState != nil ? #imageLiteral(resourceName: "btnCheck") : #imageLiteral(resourceName: "btnUncheck"), for: .normal)
        self.fixedImageView.alpha = checkState != nil ? 0.5 : 1.0
    }
    
    private func bindButtons() {
        self.checkButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self._delegate?.journeyTodoTableViewCell(self, didTapCheck: "")
            })
            .disposed(by: self.disposeBag)
    }
    
    private static let screenRatio: CGFloat = DeviceInfo.screenWidth / 375
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var fixedImageView: UIImageView!
    @IBOutlet private weak var todoLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    
}
