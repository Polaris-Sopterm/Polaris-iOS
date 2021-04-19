//
//  AddTodoDropdownTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit
import RxSwift

class AddTodoDropdownTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat { return UITableView.automaticDimension }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupTableView()
    }
    
    // MARK: - Set Up
    private func setupTableView() {
    }
    
    // MARK: - Bind
    
    
    private static let duration: TimeInterval       = 0.7
    private static let screenRatio: CGFloat         = DeviceInfo.screenWidth / 375
    private static let menuCellHeight: CGFloat      = 56 * screenRatio
    
    var disposeBag = DisposeBag()
}

extension AddTodoDropdownTableViewCell: UITableViewDelegate {
}
