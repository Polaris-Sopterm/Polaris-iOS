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
        
        #warning("추가한 TodoList 가져오는 API")
//        self.viewModel.requestTodoList()
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
                
                let currentTab               = self.viewModel.currentTabRelay.value
                let changedTab: TodoCategory = currentTab == .day ? .journey : .day
                self.viewModel.currentTabRelay.accept(changedTab)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeCategory() {
        self.viewModel.currentTabRelay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] currentTab in
                guard let self = self else { return }
                
                self.tableView.reloadData()
//                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                self.tableView.setContentOffset(CGPoint(x: 0, y: -type(of: self).navigationHeight), animated: false)
                self.updateCategoryButton(as: currentTab == .day ? .journey : .day)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateCategoryButton(as category: TodoCategory) {
        self.categoryButton.setTitle(category.title, for: .normal)
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
        let currentTab = self.viewModel.currentTabRelay.value
        if currentTab == .day { return Date.WeekDay.allCases.count }
        else                  { return 0 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentTab = self.viewModel.currentTabRelay.value
        if currentTab == .day {
            guard let currentDate = self.viewModel.todoDayHeaderModel[safe: section] else { return 0 }
            return self.viewModel.todoDayListTable[currentDate]?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentTab = self.viewModel.currentTabRelay.value
        guard let todoCell = tableView.dequeueReusableCell(cell: currentTab.cellType, forIndexPath: indexPath) else { return UITableViewCell() }
        
        return todoCell
    }
    
}

extension TodoTableViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellType = self.viewModel.currentTabRelay.value.cellType
        return currentCellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let currentHeaderType = self.viewModel.currentTabRelay.value.headerType
        return currentHeaderType.headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentTab = self.viewModel.currentTabRelay.value
        var todoHeaderView: TodoHeaderView
        
        if currentTab == .day {
            guard let dayHeaderView: DayTodoHeaderView = UIView.fromNib()     else { return nil }
            guard let date = self.viewModel.todoDayHeaderModel[safe: section] else { return nil }
            dayHeaderView.configure(date)
            todoHeaderView = dayHeaderView
        } else {
            guard let journeyHeaderView: JourneyTodoHeaderView = UIView.fromNib() else { return nil }
            todoHeaderView = journeyHeaderView
        }
        
        todoHeaderView.delegate = self
        
        return todoHeaderView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let superTableView = self.superTableView else { return }
        guard superTableView.isDragging == true        else { return }

        let originPoint = CGPoint(x: 0, y: -type(of: self).navigationHeight)
        scrollView.setContentOffset(originPoint, animated: false)
    }
    
}

extension TodoTableViewCell: DayTodoHeaderViewDelegate {
    
    func dayTodoHeaderView(_ dayTodoHeaderView: DayTodoHeaderView, didTapAddTodo date: String) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        addTodoVC.setupAddOptions(.perDayAddTodo)
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
}

extension TodoTableViewCell: JourneyTodoHeaderViewDelegate {
    
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapEdit todo: String) {
    }
    
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapAdd todo: String) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        addTodoVC.setupAddOptions(.perJourneyAddTodo)
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
}
