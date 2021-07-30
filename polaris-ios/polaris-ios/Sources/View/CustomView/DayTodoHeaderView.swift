//
//  DayTodoHeaderView.swift
//  polaris-ios
//
//  Created by USER on 2021/05/16.
//

import RxCocoa
import RxSwift
import UIKit

protocol DayTodoHeaderViewDelegate: TodoHeaderViewDelegate {
    func dayTodoHeaderView(_ dayTodoHeaderView: DayTodoHeaderView, didTapAddTodo date: Date)
}

class DayTodoHeaderView: TodoHeaderView {
    
    override static var headerHeight: CGFloat { return (58 * screenRatio) + (2 * verticalInset) }
    override weak var delegate: TodoHeaderViewDelegate? {
        didSet { self._delegate = self.delegate as? DayTodoHeaderViewDelegate }
    }
    
    func configure(_ date: Date) {
        self.date = date
        
        self.dayLabel.text = date.convertToString(using: "M월 d일 EEEE")
        date.normalizedDate == Date().normalizedDate ? self.updateUI(as: .today) : self.updateUI(as: .other)
    }

    private func updateUI(as headerType: HeaderType) {
        self.effectImageView.image          = headerType.effectImage
        self.dayLabel.textColor             = headerType.textColor
        self.backgroundView.backgroundColor = headerType.backgroundColor
        
        switch headerType {
        case .today:
            self.effectTrailingConstraint.constant = 29
            self.effectWidthConstraint.constant    = 166 * type(of: self).screenRatio
        case .other:
            self.effectTrailingConstraint.constant = 0
            self.effectWidthConstraint.constant    = 246 * type(of: self).screenRatio
        }
        
        self.layoutIfNeeded()
    }
    
    private func bindButtons() {
        self.addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self             else { return }
                guard let addTodoDate = self.date else { return }
                self._delegate?.dayTodoHeaderView(self, didTapAddTodo: addTodoDate)
            })
            .disposed(by: self.disposeBag)
    }
    
    private static let verticalInset: CGFloat = 5
    private static let screenRatio: CGFloat   = DeviceInfo.screenWidth / 375
    
    private var date: Date?
    
    private var disposeBag = DisposeBag()
    private weak var _delegate: DayTodoHeaderViewDelegate?
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var dayLabel: UILabel!
    
    @IBOutlet private weak var effectImageView: UIImageView!
    @IBOutlet private weak var effectWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var effectTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var addButton: UIButton! { didSet { self.bindButtons() } }
    
}

extension DayTodoHeaderView {
    enum HeaderType {
        case today
        case other
        
        var effectImage: UIImage? {
            switch self {
            case .today: return #imageLiteral(resourceName: "imgSkyShining.png")
            case .other: return #imageLiteral(resourceName: "imgPurpleShining.png")
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .today: return .inactiveSky
            case .other: return .inactivePurple
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .today: return .textSky
            case .other: return .maintext
            }
        }
    }
}
