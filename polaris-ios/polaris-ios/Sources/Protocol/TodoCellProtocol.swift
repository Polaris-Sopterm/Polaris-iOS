//
//  TodoCellProtocol.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/18.
//

import RxSwift
import UIKit

protocol TodoModelProtocol { }

protocol TodoHeaderViewDelegate: AnyObject { }

protocol TodoCategoryCellDelegate: AnyObject {
    func todoCategoryCell(_ cell: TodoCategoryCell, category: TodoCategory, isExpanded: Bool, forRowAt indexPath: IndexPath)
}

class TodoHeaderView: UIView {
    
    weak var delegate: TodoHeaderViewDelegate?
    class var headerHeight: CGFloat { return 0 }
    
}

class TodoCategoryCell: UITableViewCell {
    
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    
    class var expandedConstant: CGFloat { return -112 }
    class var cellHeight: CGFloat       { return 0 }
    
    weak var delegate: TodoCategoryCellDelegate?
    
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindPanGesture()
    }
    
    func configure(_ todoModel: TodoModelProtocol) {}
    
    func expandCell(isExpanded: Bool, animated: Bool) {
        self.layoutForExpaned(isExpaned: isExpanded, animated: animated)
    }
    
    private func bindPanGesture() {
        let panGesture = HorizonPanableGesture()
        panGesture.setDelegate()

        panGesture.rx.event.observeOnMain(onNext: { [weak self] panGesture in
            guard let self = self                else { return }
            guard let indexPath = self.indexPath else { return }

            let transition = panGesture.translation(in: self)
            let changedY   = transition.x + self.contentViewLeadingConstraint.constant

            switch panGesture.state {
            case .cancelled, .ended, .failed:
                if changedY <= (type(of: self).expandedConstant / 2) {
                    let category: TodoCategory = self is DayTodoTableViewCell ? .day : .journey
                    self.delegate?.todoCategoryCell(self, category: category, isExpanded: true, forRowAt: indexPath)
                    self.layoutForExpaned(isExpaned: true)
                } else {
                    self.layoutForExpaned(isExpaned: false)
                }
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
    
    func layoutForExpaned(isExpaned: Bool, animated: Bool = true) {
        self.contentViewLeadingConstraint.constant = isExpaned ? type(of: self).expandedConstant : 0
        
        guard animated == true else { self.layoutIfNeeded(); return }
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    private let disposeBag = DisposeBag()
    
}
