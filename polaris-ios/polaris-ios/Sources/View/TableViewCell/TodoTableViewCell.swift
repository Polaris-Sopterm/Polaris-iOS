//
//  TodoByDayTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/17.
//

import RxCocoa
import RxSwift
import UIKit

class TodoCustomTableView: UITableView, UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: self) else { return true }
        guard self.contentOffset.y == -(51 + DeviceInfo.topSafeAreaInset) else { return true }
        if velocity.y < 0 { return true }
        else              { return false }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        
        if self.contentOffset.y <= -(51 + DeviceInfo.topSafeAreaInset) {
            if panGesture.velocity(in: self).y < 0 { return false }
            else                                   { return true }
        } else {
            return false
        }
    }
    
}

class TodoTableViewCell: MainTableViewCell {
    
    override static var cellHeight: CGFloat { return DeviceInfo.screenHeight }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.navigationHeightConstraint.constant = type(of: self).navigationHeight
        self.registerCell()
        self.setupTableView()
        self.bindButtons()
        self.observeCategory()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupSuperTableView()
    }
    
    private func setupSuperTableView() {
        self.superTableView = self.superview as? UITableView
    }
    
    private func registerCell() {
        self.tableView.registerCell(cell: DayTodoTableViewCell.self)
        self.tableView.registerCell(cell: JourneyTodoTableViewCell.self)
    }
    
    private func setupTableView() {
        self.tableView.delegate                       = self
        self.tableView.dataSource                     = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.contentInset                   = UIEdgeInsets(top: type(of: self).navigationHeight,
                                                                     left: 0,
                                                                     bottom: 0,
                                                                     right: 0)
    }
    
    private func bindButtons() {
        self.categoryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                let currentTab = self.viewModel.currentTab
                self.viewModel.update(tab: currentTab == .day ? .journey : .day)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeCategory() {
        self.viewModel.reloadSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
        
    }
    
    private static var navigationHeight: CGFloat { return 51 + DeviceInfo.topSafeAreaInset }
    
    private let viewModel  = TodoViewModel()
    private let disposeBag = DisposeBag()
    
    private weak var superTableView: UITableView?
    @IBOutlet private weak var navigationHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: TodoCustomTableView!
    @IBOutlet private weak var categoryButton: UIButton!
    
}

extension TodoTableViewCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentTab = self.viewModel.currentTab
        guard let todoCell = tableView.dequeueReusableCell(cell: currentTab.cellType, forIndexPath: indexPath) else { return UITableViewCell() }
        
        return todoCell
    }
    
}

extension TodoTableViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellType = self.viewModel.currentTab.cellType
        return currentCellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return JourneyTodoHeaderView.headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let journeyTodoHeaderView: JourneyTodoHeaderView = UIView.fromNib() else { return nil }
        
        if section == 0 { journeyTodoHeaderView.setUI(as: .today) }
        else            { journeyTodoHeaderView.setUI(as: .other) }
        
        journeyTodoHeaderView.delegate = self
        
        return journeyTodoHeaderView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let superTableView = self.superTableView else { return }
        guard superTableView.isDragging == true        else { return }

        let originPoint = CGPoint(x: 0, y: -type(of: self).navigationHeight)
        scrollView.setContentOffset(originPoint, animated: false)
    }
    
}

extension TodoTableViewCell: JourneyTodoHeaderViewDelegate {
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapAddTodo date: String) {
        #warning("데이터 대입했을 때, 구현 필요")
        print(date)
    }
}

extension TodoTableViewCell: DayTodoTableViewCellDelegate {
    func dayTodoTableViewCell(_ journeyTodoTableViewCell: DayTodoTableViewCell, didTapCheck todo: String) {
        #warning("여기도 처리 코드 필요 아마 API 요청이 될 듯")
        print("todo")
    }
}
