//
//  JourneyTodoTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/05/16.
//

import RxCocoa
import RxSwift
import UIKit

final class CustomPanGesture: UIPanGestureRecognizer, UIGestureRecognizerDelegate {
    
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
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapCheck todo: TodoDayPerModel)
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapEdit todo: TodoDayPerModel)
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapDelete todo: TodoDayPerModel)
}

final class DayTodoTableViewCell: TodoCategoryCell {
    
    override static var cellHeight: CGFloat { return 63 * self.screenRatio }
    
    override weak var delegate: TodoCategoryCellDelegate? {
        didSet {
            self._delegate = self.delegate as? DayTodoTableViewCellDelegate
        }
    }
    
    weak var _delegate: DayTodoTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
        self.bindPanGesture()
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
            
            self.animateToInitial()
            self._delegate?.dayTodoTableViewCell(self, didTapEdit: todoModel)
        }).disposed(by: self.disposeBag)
        
        self.deleteButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self                else { return }
            guard let todoModel = self.todoModel else { return }
            
            self.animateToInitial()
            self._delegate?.dayTodoTableViewCell(self, didTapDelete: todoModel)
        }).disposed(by: self.disposeBag)
    }
    
    private func bindPanGesture() {
        let panGesture = CustomPanGesture()
        panGesture.setDelegate()

        panGesture.rx.event.observeOnMain(onNext: { [weak self] panGesture in
            guard let self = self else { return }

            let transition = panGesture.translation(in: self)
            let changedY   = transition.x + self.contentViewLeadingConstraint.constant

            switch panGesture.state {
            case .cancelled, .ended, .failed:
                if changedY <= -56 { self.animateToExpanding() }
                else               { self.animateToInitial() }
            case .changed:
                guard changedY >= -112 && changedY <= 0 else { return }
                self.contentViewLeadingConstraint.constant = changedY
            default:
                break
            }

            panGesture.setTranslation(.zero, in: self)
        }).disposed(by: self.disposeBag)
        self.addGestureRecognizer(panGesture)
    }
    
    private func animateToExpanding() {
        self.contentViewLeadingConstraint.constant = -112
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func animateToInitial() {
        self.contentViewLeadingConstraint.constant = 0
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    private static let screenRatio: CGFloat = DeviceInfo.screenWidth / 375
    
    private let disposeBag = DisposeBag()
    private var todoModel: TodoDayPerModel?
    
    @IBOutlet private weak var fixImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    
    @IBOutlet private weak var contentViewLeadingConstraint: NSLayoutConstraint!
    
}
