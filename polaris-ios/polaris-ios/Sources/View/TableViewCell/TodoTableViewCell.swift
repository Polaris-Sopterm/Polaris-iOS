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
        self.observeViewModel()
        
        self.viewModel.requestTodoDayList(shouldScroll: true)
        self.viewModel.requestTodoJourneyList()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupSuperTableView()
    }
    
    private func setupSuperTableView() {
        self.superTableView = self.superview as? UITableView
    }
    
    private func registerCell() {
        self.tableView.registerCell(cell: TodoListEmptyTableViewCell.self)
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
        self.categoryButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            let currentTab               = self.viewModel.currentTabRelay.value
            let changedTab: TodoCategory = currentTab == .day ? .journey : .day
            self.viewModel.updateCurrentTab(changedTab)
        }).disposed(by: self.disposeBag)
    }
    
    private func observeViewModel() {
        self.viewModel.currentTabRelay
            .distinctUntilChanged()
            .observeOnMain(onNext: { [weak self] currentTab in
                guard let self = self else { return }
                
                self.tableView.reloadData()
                
                if self.viewModel.currentTabRelay.value == .day {
                    self.scrollToCurrentDay()
                } else {
                    self.viewModel.todoJourneyList.isEmpty ?
                        self.tableView.setContentOffset(CGPoint(x: 0, y: type(of: self).navigationHeight), animated: false) :
                        self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                }
                self.updateCategoryButton(as: currentTab == .day ? .journey : .day)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.reloadSubject.observeOnMain(onNext: { [weak self] shouldScroll in
            self?.tableView.reloadData()
            
            if self?.viewModel.currentTabRelay.value == .day && shouldScroll { self?.scrollToCurrentDay() }
        }).disposed(by: self.disposeBag)
    }
    
    private func updateCategoryButton(as category: TodoCategory) {
        self.categoryButton.setTitle(category.title, for: .normal)
    }
    
    private func scrollToCurrentDay() {
        let currentDate = Date.normalizedCurrent
        
        guard let currentSection = self.viewModel.todoDayHeadersInform.firstIndex(of: currentDate) else { return }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: currentSection),
                                   at: .top,
                                   animated: false)
    }
    
    private func todoCategoryCell(at indexPath: IndexPath) -> TodoCategoryCell? {
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        return cell as? TodoCategoryCell
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
        else                  { return self.viewModel.todoJourneyList.count }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.todoListNumberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.viewModel.isEmptyDayTodoSection(at: indexPath.section) {
            guard let emptyCell = tableView.dequeueReusableCell(cell: TodoListEmptyTableViewCell.self,
                                                                forIndexPath: indexPath) else {
                return UITableViewCell()
            }
            return emptyCell
        }
        
        let currentTab       = self.viewModel.currentTabRelay.value
        let todoList         = self.viewModel.todoList(at: indexPath.section)
        let cell             = tableView.dequeueReusableCell(cell: currentTab.cellType, forIndexPath: indexPath)
        let expanedIndexPath = self.viewModel.expanedCellIndexPath(of: currentTab)
        
        guard let todoCell = cell                           else { return UITableViewCell() }
        guard let todoModel = todoList[safe: indexPath.row] else { return UITableViewCell() }
        
        todoCell.delegate  = self
        todoCell.indexPath = indexPath
        todoCell.configure(todoModel)
        todoCell.expandCell(isExpanded: indexPath == expanedIndexPath, animated: false)
        return todoCell
    }
    
}

extension TodoTableViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.viewModel.isEmptyDayTodoSection(at: indexPath.section) { return TodoListEmptyTableViewCell.cellHeight }
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
            guard let dayHeaderView: DayTodoHeaderView = UIView.fromNib()       else { return nil }
            guard let date = self.viewModel.todoDayHeadersInform[safe: section] else { return nil }
            dayHeaderView.configure(date)
            todoHeaderView = dayHeaderView
        } else {
            guard let journeyHeaderView: JourneyTodoHeaderView = UIView.fromNib()  else { return nil }
            guard let journeyModel = self.viewModel.todoJourneyList[safe: section] else { return nil }
            journeyHeaderView.configure(journeyModel)
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
    
    func dayTodoHeaderView(_ dayTodoHeaderView: DayTodoHeaderView, didTapAddTodo date: Date) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        addTodoVC.setAddOptions(.perDayAddTodo)
        addTodoVC.setAddTodoDate(date)
        addTodoVC.delegate = self
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
}

extension TodoTableViewCell: JourneyTodoHeaderViewDelegate {
    
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapEdit todo: WeekJourneyModel) {
    }
    
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapAdd todo: WeekJourneyModel) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        addTodoVC.setAddOptions(.perJourneyAddTodo)
        addTodoVC.setAddTodoJourney(todo)
        addTodoVC.delegate = self
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
}

extension TodoTableViewCell: TodoCategoryCellDelegate {
    
    func todoCategoryCell(_ cell: TodoCategoryCell, category: TodoCategory, isExpanded: Bool, forRowAt indexPath: IndexPath) {
        guard self.viewModel.currentTabRelay.value == category else { return }
        
        defer { self.viewModel.updateExpanedStatus(category: category, forRowAt: indexPath, isExpanded: isExpanded) }
        
        guard isExpanded == true else { return }
        guard let currentExpandedIndexPath
                = category == .day ? self.viewModel.dayExpanedIndexPath : self.viewModel.journeyExpanedIndexPath else { return }
        self.todoCategoryCell(at: currentExpandedIndexPath)?.expandCell(isExpanded: false, animated: true)
    }

}

extension TodoTableViewCell: DayTodoTableViewCellDelegate {
    
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapCheck todo: TodoModel) {
        self.viewModel.updateDoneStatus(todo)
    }
    
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapEdit todo: TodoModel) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        
        addTodoVC.setAddOptions(.edittedTodo)
        addTodoVC.setEditTodo(todo)
        addTodoVC.delegate = self
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapDelete todo: TodoModel) {
        guard let todoIdx = todo.idx else { return }
        self.viewModel.requestDeleteTodo(todoIdx)
    }
    
}

extension TodoTableViewCell: JourneyTodoTableViewDelegate {
    
    func journeyTodoTableViewCell(_ cell: JourneyTodoTableViewCell, didTapCheck todo: TodoModel) {
        
    }
    
    func journeyTodoTableViewCell(_ cell: JourneyTodoTableViewCell, didTapEdit todo: TodoModel) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        
        addTodoVC.setAddOptions(.edittedTodo)
        addTodoVC.setEditTodo(todo)
        addTodoVC.delegate = self
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
    func journeyTodoTableViewCell(_ cell: JourneyTodoTableViewCell, didTapDelete todo: TodoModel) {
        guard let todoIdx = todo.idx else { return }
        self.viewModel.requestDeleteTodo(todoIdx)
    }
    
}

extension TodoTableViewCell: AddTodoViewControllerDelegate {
    
    func addTodoViewController(_ viewController: AddTodoVC, didCompleteAddOption option: AddTodoVC.AddOptions) {
        if option == .perDayAddTodo {
            self.viewModel.requestTodoDayList(shouldScroll: false)
            self.viewModel.requestTodoJourneyList()
        } else if option == .perJourneyAddTodo {
            self.viewModel.requestTodoDayList(shouldScroll: false)
            self.viewModel.requestTodoJourneyList()
        } else if option == .edittedTodo {
            self.viewModel.requestTodoDayList(shouldScroll: false)
            self.viewModel.requestTodoJourneyList()
        }
    }
    
}
