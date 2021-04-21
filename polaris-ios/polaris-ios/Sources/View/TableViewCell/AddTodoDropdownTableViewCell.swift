//
//  AddTodoDropdownTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit
import RxSwift
import RxCocoa

class AddTodoDropdownTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat { return UITableView.automaticDimension }
    
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.registerCell()
        self.bindButton()
        self.setupContainerView()
        self.bindTableView()
    }
    
    // MARK: - Set Up
    private func setupContainerView() {
        self.containerView.makeRounded(cornerRadius: 16)
    }
    
    private func registerCell() {
        self.tableView.registerCell(cell: DropdownItemTableViewCell.self)
    }
    
    // MARK: - Bind
    private func bindButton() {
        self.dropdownButton.rx.tap
            .subscribe(onNext: {
                guard let expaned = try? self.viewModel.isExpanded.value() else { return }
                
                self.viewModel.isExpanded.onNext(!expaned)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isExpanded
            .subscribe(onNext: { expanded in
                if expanded {
                    self.tableViewHeightConstraint.constant = 341
                } else {
                    self.tableViewHeightConstraint.constant = 0
                }
                
                UIView.animate(withDuration: type(of: self).duration) {
                    self.layoutIfNeeded()
                }
                
                (self.superview as? UITableView)?.beginUpdates()
                (self.superview as? UITableView)?.endUpdates()
            })
            .disposed(by: self.disposeBag)
            
    }
    
    private func bindTableView() {
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.viewModel.menus
            .bind(to: self.tableView.rx.items) { tableView, index, item in
                guard let dropdownCell = tableView.dequeueReusableCell(cell: DropdownItemTableViewCell.self, forIndexPath: IndexPath(row: index, section: 0)) else { return UITableViewCell() }
                dropdownCell.configure(by: item)
                return dropdownCell
            }
            .disposed(by: self.disposeBag)
    }
    
    private static let duration: TimeInterval       = 0.7
    private static let screenRatio: CGFloat         = DeviceInfo.screenWidth / 375
    private static let menuCellHeight: CGFloat      = 56 * screenRatio
    
    private static let selectBorderColor: UIColor   = UIColor.mainSky
    
    var viewModel  = AddTodoDropdownViewModel()
    var disposeBag = DisposeBag()
}

extension AddTodoDropdownTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).menuCellHeight
    }
}
