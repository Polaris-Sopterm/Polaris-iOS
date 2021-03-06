//
//  JourneyTodoHeaderView.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/18.
//

import RxCocoa
import RxSwift
import UIKit

protocol JourneyTodoHeaderViewDelegate: TodoHeaderViewDelegate {
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapEdit todo: WeekJourneyModel)
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapAdd todo: WeekJourneyModel)
}

class JourneyTodoHeaderView: TodoHeaderView {

    override static var headerHeight: CGFloat { return 85 * screenRatio }
    override weak var delegate: TodoHeaderViewDelegate? {
        didSet { self._delegate = self.delegate as? JourneyTodoHeaderViewDelegate }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
    }
    
    override func configure(_ presentable: TodoSectionHeaderPresentable) {
        super.configure(presentable)
        
        guard let journeyHeader = presentable as? WeekJourneyModel else { return }
        self.journeyModel = journeyHeader
        
        self.titleLabel.text = journeyHeader.title != "default" ? journeyHeader.title : "여정이 없는 할 일"
        self.editButton.isHidden = journeyHeader.title == "default"
        
        self.firstStarCategoryView.isHidden          = journeyHeader.value1 == nil
        self.firstCategoryLabel.text                 = journeyHeader.value1
        self.firstCategoryColorView.backgroundColor  = journeyHeader.firstValueJourney?.color
        
        self.secondStarCategoryView.isHidden         = journeyHeader.value2 == nil
        self.secondCategoryLabel.text                = journeyHeader.value2
        self.secondCategoryColorView.backgroundColor = journeyHeader.secondValueJourney?.color
    }
    
    private func bindButtons() {
        self.editButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self                      else { return }
            guard let journeyModel = self.journeyModel else { return }
            self._delegate?.journeyTodoHeaderView(self, didTapEdit: journeyModel)
        }).disposed(by: self.disposeBag)
        
        self.addButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self                      else { return }
            guard let journeyModel = self.journeyModel else { return }
            self._delegate?.journeyTodoHeaderView(self, didTapAdd: journeyModel)
        }).disposed(by: self.disposeBag)
    }
    
    private static var screenRatio: CGFloat { return DeviceInfo.screenWidth / 375 }
    
    private let disposeBag = DisposeBag()
    private var journeyModel: WeekJourneyModel?

    private weak var _delegate: JourneyTodoHeaderViewDelegate?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    
    @IBOutlet private weak var firstStarCategoryView: UIView!
    @IBOutlet private weak var firstCategoryColorView: UIView!
    @IBOutlet private weak var firstCategoryLabel: UILabel!
    
    @IBOutlet private weak var secondStarCategoryView: UIView!
    @IBOutlet private weak var secondCategoryColorView: UIView!
    @IBOutlet private weak var secondCategoryLabel: UILabel!
    
    
}
