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
    func journeyTodoTableViewCell(_ cell: JourneyTodoTableViewCell, didTapCheck todo: TodoModel)
    func journeyTodoTableViewCell(_ cell: JourneyTodoTableViewCell, didTapEdit todo: TodoModel)
    func journeyTodoTableViewCell(_ cell: JourneyTodoTableViewCell, didTapDelete todo: TodoModel)
}

class JourneyTodoTableViewCell: TodoCategoryCell {
    
    override static var cellHeight: CGFloat       { return 63 * self.screenRatio }
    override static var expandedConstant: CGFloat { return super.expandedConstant }
    
    override var delegate: TodoCategoryCellDelegate? {
        didSet {
            self._delegate = delegate as? JourneyTodoTableViewDelegate
        }
    }
    
    weak var _delegate: JourneyTodoTableViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
    }
    
    override func configure(_ todoModel: TodoModel) {
        super.configure(todoModel)
        
        self.todoLabel.text          = todoModel.title
        self.dayLabel.text           = todoModel.date
        self.fixedImageView.isHidden = todoModel.isTop == false
        
        self.updateUI(as: todoModel.isDone)
    }
    
    func updateUI(as checkState: String?) {
        self.todoLabel.textColor = checkState != nil ? .inactiveTextPurple : .maintext
        self.dayLabel.textColor  = checkState != nil ? .inactiveTextPurple : .maintext
        self.checkButton.setImage(checkState != nil ? #imageLiteral(resourceName: "btnCheck") : #imageLiteral(resourceName: "btnUncheck"), for: .normal)
        self.fixedImageView.alpha = checkState != nil ? 0.5 : 1.0
    }
    
    private func bindButtons() {
        self.checkButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self                else { return }
                guard let todoModel = self.todoModel else { return }
                
                self._delegate?.journeyTodoTableViewCell(self, didTapCheck: todoModel)
            })
            .disposed(by: self.disposeBag)
        
        self.editButton.rx.tap.observeOnMain(onNext: { [weak self] in
            guard let self = self                else { return }
            guard let todoModel = self.todoModel else { return }
            guard let indexPath = self.indexPath else { return }
            
            self.layoutForExpaned(isExpaned: false, animated: true)
            self._delegate?.journeyTodoTableViewCell(self, didTapEdit: todoModel)
            self.delegate?.todoCategoryCell(self, category: .journey, isExpanded: false, forTodo: todoModel)
        }).disposed(by: self.disposeBag)
        
        self.deleteButton.rx.tap.observeOnMain(onNext: { [weak self] in
            guard let self = self                else { return }
            guard let todoModel = self.todoModel else { return }
            guard let indexPath = self.indexPath else { return }
            
            self.layoutForExpaned(isExpaned: false, animated: true)
            self._delegate?.journeyTodoTableViewCell(self, didTapDelete: todoModel)
            self.delegate?.todoCategoryCell(self, category: .journey, isExpanded: false, forTodo: todoModel)
        }).disposed(by: self.disposeBag)
    }
    
    private static let screenRatio: CGFloat = DeviceInfo.screenWidth / 375
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var fixedImageView: UIImageView!
    @IBOutlet private weak var todoLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    
}
