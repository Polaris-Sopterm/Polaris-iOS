//
//  AddTodoDropdownTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit
import RxSwift
import RxCocoa

protocol AddTodoDropdownTableViewCellDelegate: AddTodoTableViewCellDelegate {
    func addTodoDropdownTableViewCell(_ addTodoDropdownTableViewCell: AddTodoDropdownTableViewCell, didSelectedMenu menu: String)
}

class AddTodoDropdownTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat { return UITableView.automaticDimension }
    
    override weak var delegate: AddTodoTableViewCellDelegate? { didSet { self._delegate = self.delegate as? AddTodoDropdownTableViewCellDelegate } }
    weak var _delegate: AddTodoDropdownTableViewCellDelegate?
    
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.registerCell()
        self.setupContainerView()
        self.bindLabel()
        self.bindButton()
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
    private func bindLabel() {
        self.viewModel.selectedMenu
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] selectedMenu in
                guard let self = self else { return }
                
                if let selectedMenu = selectedMenu {
                    self.selectedLabel.text = selectedMenu
                    self._delegate?.addTodoDropdownTableViewCell(self, didSelectedMenu: selectedMenu)
                } else {
                    self.selectedLabel.text = "선택 안함"
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindButton() {
        self.dropdownButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self    = self else { return }
                guard let expaned = try? self.viewModel.isExpanded.value() else { return }
                
                self.viewModel.isExpanded.onNext(!expaned)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isExpanded
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] expanded in
                guard let self = self else { return }
                
                if expanded {
                    self.tableViewHeightConstraint.constant = 341
                    self.containerView.layer.borderWidth    = 1
                    self.containerView.layer.borderColor    = type(of: self).selectBorderColor.cgColor
                    
                    UIView.animate(withDuration: type(of: self).duration) {
                        self.dropdownButton.transform = CGAffineTransform(rotationAngle: .pi)
                    }
                }
                else {
                    self.tableViewHeightConstraint.constant = 0
                    self.containerView.layer.borderWidth    = 0
                    self.containerView.layer.borderColor    = UIColor.clear.cgColor
                    
                    UIView.animate(withDuration: type(of: self).duration) {
                        self.dropdownButton.transform = .identity
                    }
                }
                
                UIView.animate(withDuration: type(of: self).duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: []) {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedMenu = try? self.viewModel.menus.value()[indexPath.row] else { return }
        self.viewModel.isExpanded.onNext(false)
        self.viewModel.selectedMenu.onNext(selectedMenu)
        
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
}
