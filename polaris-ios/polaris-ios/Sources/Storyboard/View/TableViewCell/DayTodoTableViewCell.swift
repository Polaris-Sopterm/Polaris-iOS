//
//  JourneyTodoTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/05/16.
//

import RxCocoa
import RxSwift
import UIKit

final class HorizonPanableGesture: UIPanGestureRecognizer, UIGestureRecognizerDelegate {
    
    func setDelegate() {
        self.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGesture.velocity(in: UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        
        guard abs(velocity.x) > abs(velocity.y) else { return false }
        return true
    }
    
}

protocol DayTodoTableViewCellDelegate: TodoCategoryCellDelegate {
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapCheck todo: TodoModel)
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapEdit todo: TodoModel)
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapDelete todo: TodoModel)
}

final class DayTodoTableViewCell: TodoCategoryCell {
    
    override static var cellHeight: CGFloat       { return 63 * self.screenRatio }
    override static var expandedConstant: CGFloat { return super.expandedConstant }
    
    override weak var delegate: TodoCategoryCellDelegate? {
        didSet {
            self._delegate = self.delegate as? DayTodoTableViewCellDelegate
        }
    }
    
    weak var _delegate: DayTodoTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
    }
    
    override func configure(_ todoModel: TodoModel) {
        super.configure(todoModel)
        
        self.titleLabel.text        = todoModel.title
        self.subTitleLabel.text     = todoModel.journey?.title
        self.subTitleLabel.isHidden = todoModel.journey?.title == "default"
        self.fixImageView.isHidden  = todoModel.isTop == false
        
        self.updateUI(as: todoModel.isDone)
    }

    func updateUI(as checkStatus: String?) {
        let checkImage: UIImage?   = #imageLiteral(resourceName: "btnCheck")
        let uncheckImage: UIImage? = #imageLiteral(resourceName: "btnUncheck")
        
        let checkTextColor: UIColor   = .inactiveTextPurple
        let uncheckTextColor: UIColor = .maintext
        
        if checkStatus != nil {
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
    
    private func bindButtons() {
        self.checkButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self                else { return }
                guard let todoModel = self.todoModel else { return }
                
                self._delegate?.dayTodoTableViewCell(self, didTapCheck: todoModel)
            })
            .disposed(by: self.disposeBag)
        
        self.editButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self                else { return }
            guard let todoModel = self.todoModel else { return }
            guard self.indexPath != nil          else { return }
            
            self.layoutForExpaned(isExpaned: false, animated: true)
            self.delegate?.todoCategoryCell(self, category: .day, isExpanded: false, forTodo: todoModel)
            self._delegate?.dayTodoTableViewCell(self, didTapEdit: todoModel)
        }).disposed(by: self.disposeBag)
        
        self.deleteButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self                else { return }
            guard let todoModel = self.todoModel else { return }
            guard self.indexPath != nil          else { return }
            
            self.layoutForExpaned(isExpaned: false, animated: true)
            self.delegate?.todoCategoryCell(self, category: .day, isExpanded: false, forTodo: todoModel)
            self._delegate?.dayTodoTableViewCell(self, didTapDelete: todoModel)
        }).disposed(by: self.disposeBag)
    }
        
    private static let screenRatio: CGFloat = DeviceInfo.screenWidth / 375
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var fixImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    
}
