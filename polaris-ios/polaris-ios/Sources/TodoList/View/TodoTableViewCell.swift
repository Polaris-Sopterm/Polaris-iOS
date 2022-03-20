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
        if velocity.y < 0 { return true  }
        else              { return false }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        
        if self.contentOffset.y <= -(51 + DeviceInfo.topSafeAreaInset) {
            if panGesture.velocity(in: self).y < 0 { return false }
            else                                   { return true  }
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
        self.addObservers()
        self.registerCell()
        self.setupTableView()
        self.bindButtons()
        self.observeViewModel()
    }
    
    private func addObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.didUpdateTodo(_:)), name: .didUpdateTodo, object: nil)
    }
    
    private func registerCell() {
        self.tableView.registerCell(cell: TodoListEmptyTableViewCell.self)
        self.tableView.registerCell(cell: DayTodoTableViewCell.self)
        self.tableView.registerCell(cell: JourneyTodoTableViewCell.self)
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.contentInset = UIEdgeInsets(
            top: type(of: self).navigationHeight,
            left: 0,
            bottom: 0,
            right: 0
        )
    }
    
    @objc private func didUpdateTodo(_ notification: Notification) {
        guard let sceneIdentifier = notification.object as? String else { return }
        self.viewModel.occur(viewEvent: .notifyUpdateTodo(scene: sceneIdentifier))
    }
    
    private func bindButtons() {
        self.categoryButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.viewModel.occur(viewEvent: .categoryBtnTapped)
        }).disposed(by: self.disposeBag)
        
        self.addJourneyButton.rx.tap.observeOnMain(onNext: { [weak self] in            
            let viewController = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo)
            
            guard let visibleController = UIViewController.getVisibleController() else { return }
            guard let addTodoVC = viewController                                  else { return }
            addTodoVC.setAddOptions(.addJourney)
            addTodoVC.delegate = self?.viewModel
            addTodoVC.presentWithAnimation(from: visibleController)
        }).disposed(by: self.disposeBag)
    }
    
    private func observeViewModel() {
        self.viewModel.outputEventObservable
            .withUnretained(self)
            .subscribe(onNext: { owner, event in
                owner.handleOutputEvent(event)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func handleOutputEvent(_ event: TodoViewModel.OutputEvent) {
        switch event {
        case .completeDelete(let todo):
            self.showCompleteDeleteToast(ofTodo: todo)
            
        case .loading(let loading):
            self.updateLoadingIndicator(asLoading: loading)
            
        case .reload(let shouldScroll):
            self.reload(asShouldScroll: shouldScroll)
            
        case .updateCategory(let category):
            self.updateCategory(category)
        }
    }
    
    private func updateLoadingIndicator(asLoading loading: Bool) {
        self.indicatorContainerView.isHidden = loading == false
        loading ? self.indicatorView.startAnimating() : self.indicatorView.stopAnimating()
    }
    
    private func showCompleteDeleteToast(ofTodo todo: TodoModel) {
        PolarisToastManager.shared.showToast(with: "할 일이 삭제되었어요. 되돌리려면 눌러주세요.") { [weak self] in
            self?.viewModel.occur(viewEvent: .addToastTapped(todo: todo))
        }
    }
    
    private func reload(asShouldScroll shouldScroll: Bool) {
        self.tableView.reloadData()
        
        if self.viewModel.currentTab == .day {
            self.journeyEmptyView.isHidden = true
            if shouldScroll {
                self.scrollToToday()
            }
        } else {
            self.journeyEmptyView.isHidden = self.viewModel.isEmptyJourneySections == false
        }
    }
    
    private func updateCategory(_ category: TodoCategory) {
        self.tableView.reloadData()
        
        if category == .day {
            self.journeyEmptyView.isHidden = true
            self.scrollToToday()
        } else {
            self.journeyEmptyView.isHidden = self.viewModel.isEmptyJourneySections == false
            if self.viewModel.todoListNumberOfRows(in: 0) == 0 {
                self.tableView.setContentOffset(.zero, animated: false)
            } else {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        self.updateCategoryButton(as: category == .day ? .journey : .day)
    }
    
    private func updateCategoryButton(as category: TodoCategory) {
        self.categoryButton.setImage(category.buttonImage, for: .normal)
        self.categoryButton.setTitle(category.title, for: .normal)
    }
    
    private func scrollToToday() {
        let todayDate = Date.normalizedCurrent

        let todaySection = self.viewModel.daySection(ofDate: todayDate)
        self.tableView.scrollToRow(
            at: IndexPath(row: 0, section: todaySection),
            at: .top,
            animated: false
        )
    }
    
    private func todoCategoryCell(at indexPath: IndexPath) -> TodoCategoryCell? {
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        return cell as? TodoCategoryCell
    }
    
    private static var navigationHeight: CGFloat { return 51 + DeviceInfo.topSafeAreaInset }
    
    private let viewModel  = TodoViewModel()
    private let disposeBag = DisposeBag()
    
    private var superTableView: UITableView? {
        self.superview as? UITableView
    }
    
    @IBOutlet private weak var navigationHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: TodoCustomTableView!
    @IBOutlet private weak var categoryButton: UIButton!
    @IBOutlet private weak var journeyEmptyView: UIView!
    @IBOutlet private weak var addJourneyButton: UIButton!
    @IBOutlet private weak var indicatorContainerView: UIView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
}

extension TodoTableViewCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.viewModel.numberOfSections()
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
        
        let currentTab = self.viewModel.currentTab
        let todoList = self.viewModel.todoList(at: indexPath.section)
        let cell = tableView.dequeueReusableCell(cell: currentTab.cellType, forIndexPath: indexPath)
        let expanedIndexPath =
            currentTab == .day ? self.viewModel.dayExpandedTodoIndexPath : self.viewModel.journeyExpandedTodoIndexPath
        
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
        let currentCellType = self.viewModel.currentTab.cellType
        return currentCellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let currentHeaderType = self.viewModel.currentTab.headerType
        return currentHeaderType.headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentTab = self.viewModel.currentTab
        var todoHeaderView: TodoHeaderView
        
        if currentTab == .day {
            guard let dayHeaderView: DayTodoHeaderView = UIView.fromNib() else { return nil }
            todoHeaderView = dayHeaderView
        } else {
            guard let journeyHeaderView: JourneyTodoHeaderView = UIView.fromNib() else { return nil }
            todoHeaderView = journeyHeaderView
        }
        
        guard let sectionModel = self.viewModel.headerModel(of: section) else { return nil }
        todoHeaderView.configure(sectionModel)
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
        addTodoVC.delegate = self.viewModel
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
}

extension TodoTableViewCell: JourneyTodoHeaderViewDelegate {
    
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapEdit todo: WeekJourneyModel) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        addTodoVC.setJourneyModel(todo)
        addTodoVC.setAddOptions(.edittedJourney)
        addTodoVC.delegate = self.viewModel
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapAdd todo: WeekJourneyModel) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        addTodoVC.setAddOptions(.perJourneyAddTodo)
        addTodoVC.setJourneyModel(todo)
        addTodoVC.delegate = self.viewModel
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
}

extension TodoTableViewCell: TodoCategoryCellDelegate {
    
    func todoCategoryCell(_ cell: TodoCategoryCell, category: TodoCategory, isExpanded: Bool, forTodo todo: TodoModel) {
        guard self.viewModel.currentTab == category else { return }
        
        defer { self.viewModel.updateExpandedStatus(category: category, forTodo: todo, isExpanded: isExpanded) }
        
        guard isExpanded == true else { return }
        guard let currentExpandedIndexPath = category == .day ?
                self.viewModel.dayExpandedTodoIndexPath : self.viewModel.journeyExpandedTodoIndexPath else { return }
        self.todoCategoryCell(at: currentExpandedIndexPath)?.expandCell(isExpanded: false, animated: true)
    }

}

extension TodoTableViewCell: DayTodoTableViewCellDelegate {
    
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapCheck todo: TodoModel) {
        self.viewModel.occur(viewEvent: .checkBtnTapped(todo: todo))
    }
    
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapEdit todo: TodoModel) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        
        addTodoVC.setAddOptions(.edittedTodo)
        addTodoVC.setEditTodo(todo)
        addTodoVC.delegate = self.viewModel
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
    func dayTodoTableViewCell(_ cell: DayTodoTableViewCell, didTapDelete todo: TodoModel) {
        self.viewModel.occur(viewEvent: .deleteBtnTapped(todo: todo))
    }
    
}

extension TodoTableViewCell: JourneyTodoTableViewDelegate {
    
    func journeyTodoTableViewCell(_ cell: JourneyTodoTableViewCell, didTapCheck todo: TodoModel) {
        self.viewModel.occur(viewEvent: .checkBtnTapped(todo: todo))
    }
    
    func journeyTodoTableViewCell(_ cell: JourneyTodoTableViewCell, didTapEdit todo: TodoModel) {
        guard let addTodoVC = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo),
              let visibleController = UIViewController.getVisibleController() else { return }
        
        addTodoVC.setAddOptions(.edittedTodo)
        addTodoVC.setEditTodo(todo)
        addTodoVC.delegate = self.viewModel
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
    func journeyTodoTableViewCell(_ cell: JourneyTodoTableViewCell, didTapDelete todo: TodoModel) {
        self.viewModel.occur(viewEvent: .deleteBtnTapped(todo: todo))
    }
    
}
