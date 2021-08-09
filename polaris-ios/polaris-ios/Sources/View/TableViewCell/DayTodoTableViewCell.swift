//
//  JourneyTodoTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/05/16.
//

import RxCocoa
import RxSwift
import UIKit

protocol DayTodoTableViewCellDelegate: TodoCategoryCellDelegate {
    func dayTodoTableViewCell(_ dayTodoTableViewCell: DayTodoTableViewCell, didTapCheck todo: TodoDayPerModel)
}

class DayTodoTableViewCell: TodoCategoryCell {
    
    override static var cellHeight: CGFloat { return 63 * self.screenRatio }
    
    override weak var delegate: TodoCategoryCellDelegate? {
        didSet {
            self._delegate = self.delegate as? DayTodoTableViewCellDelegate
        }
    }
    
    weak var _delegate: DayTodoTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindCheckButton()
    }
    
    override func configure(_ todoListModel: TodoListModelProtocol) {
        guard let todoPerModel = todoListModel as? TodoDayPerModel else { return }
        self.todoModel = todoPerModel
        
        self.titleLabel.text        = todoPerModel.title
        self.subTitleLabel.text     = todoPerModel.journey?.title
        self.subTitleLabel.isHidden = todoPerModel.journey == nil
        self.fixImageView.isHidden  = todoPerModel.isTop == false
        
        self.updateUI(as: todoPerModel.isDone)
    }
    
    func updateUI(as checkStatus: Bool?) {
        guard let checkStatus = checkStatus else { return }
        
        let checkImage: UIImage?   = #imageLiteral(resourceName: "btnCheck")
        let uncheckImage: UIImage? = #imageLiteral(resourceName: "btnUncheck")
        
        let checkTextColor: UIColor   = .inactiveTextPurple
        let uncheckTextColor: UIColor = .maintext
        
        if checkStatus == true {
            self.titleLabel.textColor    = checkTextColor
            self.subTitleLabel.textColor = checkTextColor
            self.fixImageView.alpha      = 0.5
            self.checkButton.setImage(checkImage, for: .normal)
        } else {
            self.titleLabel.textColor    = uncheckTextColor
            self.subTitleLabel.textColor = uncheckTextColor
            self.fixImageView.alpha      = 1
            self.checkButton.setImage(uncheckImage, for: .normal)
        }
    }
    
    private func bindCheckButton() {
        self.checkButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self                else { return }
                guard let todoModel = self.todoModel else { return }
                
                self._delegate?.dayTodoTableViewCell(self, didTapCheck: todoModel)
            })
            .disposed(by: self.disposeBag)
    }
    
    private static let screenRatio: CGFloat = DeviceInfo.screenWidth / 375
    
    private var disposeBag = DisposeBag()
    
    private var todoModel: TodoDayPerModel?
    
    @IBOutlet private weak var fixImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var checkButton: UIButton!
    
}
