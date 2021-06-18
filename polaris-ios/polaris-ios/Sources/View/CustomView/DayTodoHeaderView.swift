//
//  DayTodoHeaderView.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/18.
//

import RxCocoa
import RxSwift
import UIKit

protocol DayTodoHeaderViewDelegate: TodoHeaderViewDelegate {
    func dayTodoHeaderView(_ dayTodoHeaderView: DayTodoHeaderView, didTapEdit todo: String)
    func dayTodoHeaderView(_ dayTodoHeaderView: DayTodoHeaderView, didTapAdd todo: String)
}

class DayTodoHeaderView: TodoHeaderView {

    override static var headerHeight: CGFloat { return 85 * screenRatio }
    override weak var delegate: TodoHeaderViewDelegate? {
        didSet { self._delegate = self.delegate as? DayTodoHeaderViewDelegate }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindButtons()
    }
    
    private func bindButtons() {
        self.editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self._delegate?.dayTodoHeaderView(self, didTapEdit: "")
            })
            .disposed(by: self.disposeBag)
        
        self.addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self._delegate?.dayTodoHeaderView(self, didTapAdd: "")
            })
            .disposed(by: self.disposeBag)
    }
    
    private static var screenRatio: CGFloat { return DeviceInfo.screenWidth / 375 }
    
    private let disposeBag = DisposeBag()

    private weak var _delegate: DayTodoHeaderViewDelegate?
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var firstStarCategoryView: UIView!
    @IBOutlet private weak var secondStarCategoryView: UIView!
    
}
