//
//  JourneyTodoHeaderView.swift
//  polaris-ios
//
//  Created by USER on 2021/05/16.
//

import RxCocoa
import RxSwift
import UIKit

protocol JourneyTodoHeaderViewDelegate: AnyObject {
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapAddTodo date: String)
}

class JourneyTodoHeaderView: UIView {
    
    static var headerHeight: CGFloat = (58 * screenRatio) + (2 * verticalInset)
    
    weak var delegate: JourneyTodoHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindAddButton()
    }
    
    func setUI(as headerType: HeaderType) {
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
    
    private func bindAddButton() {
        self.addButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                #warning("여기에 AddTodo 하는 날짜 넘기는 코드 필요")
                self.delegate?.journeyTodoHeaderView(self, didTapAddTodo: "")
            })
            .disposed(by: self.disposeBag)
    }
    
    private static let verticalInset: CGFloat = 5
    private static let screenRatio: CGFloat   = DeviceInfo.screenWidth / 375
    
    private var disposeBag = DisposeBag()
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var dayLabel: UILabel!
    
    @IBOutlet private weak var effectImageView: UIImageView!
    @IBOutlet private weak var effectWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var effectTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var addButton: UIButton!
    
}

extension JourneyTodoHeaderView {
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
