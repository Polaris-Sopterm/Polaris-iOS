//
//  JourneyTodoVC.swift
//  polaris-ios
//
//  Created by USER on 2021/05/16.
//

import RxCocoa
import RxSwift
import UIKit

class JourneyTodoVC: UIViewController {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationHeightConstraint.constant = type(of: self).navigationHeight
    }
    
    private func registerCell() {
        self.tableView.registerCell(cell: JourneyTodoTableViewCell.self)
    }
    
    private func setupTableView() {
        self.tableView.delegate     = self
        self.tableView.dataSource   = self
        self.tableView.contentInset = UIEdgeInsets(top: type(of: self).navigationHeight + 10,
                                                   left: 0,
                                                   bottom: 0,
                                                   right: 0)
    }
    
    private static var navigationHeight: CGFloat { return 51 + DeviceInfo.topSafeAreaInset }
    
    @IBOutlet private weak var navigationHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    
}

extension JourneyTodoVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let journeyTodoCell = tableView.dequeueReusableCell(cell: JourneyTodoTableViewCell.self, forIndexPath: indexPath) else { return UITableViewCell() }
        return journeyTodoCell
    }
}

extension JourneyTodoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return JourneyTodoTableViewCell.cellHeight
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
}

extension JourneyTodoVC: JourneyTodoHeaderViewDelegate {
    func journeyTodoHeaderView(_ journeyTodoHeaderView: JourneyTodoHeaderView, didTapAddTodo date: String) {
        #warning("데이터 대입했을 때, 구현 필요")
        print(date)
    }
}
