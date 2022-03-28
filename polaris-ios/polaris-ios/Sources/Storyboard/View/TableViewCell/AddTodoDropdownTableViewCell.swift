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
    func addTodoDropdownTableViewCell(_ addTodoDropdownTableViewCell: AddTodoDropdownTableViewCell, didSelectedJourney journey: JourneyTitleModel)
}

class AddTodoDropdownTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat { return UITableView.automaticDimension }
    
    override weak var delegate: AddTodoTableViewCellDelegate? {
        didSet { self._delegate = self.delegate as? AddTodoDropdownTableViewCellDelegate }
    }
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCell()
        self.setupContainerView()
        self.bindLabel()
        self.bindButton()
        self.bindTableView()
    }
    
    override func configure(by addMode: AddTodoVC.AddMode, date: Date? = nil) {
        super.configure(by: addMode, date: date)
        
        self.viewModel.requestJourneyList(date)
        
        switch addMode {
        case .editTodo(let todo):
            let defaultJourney = JourneyTitleModel(
                idx: nil,
                title: "default",
                year: nil,
                month: nil,
                weekNo: nil,
                userIdx: nil
            )
            let journey = todo.journey ?? defaultJourney
            self.updateSelectedJourney(journey)
            
        default:
            break
        }
    }
    
    private func updateSelectedJourney(_ journey: JourneyTitleModel) {
        self.viewModel.updateSelectedMenu(journey)
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
        self.viewModel.selectedMenu.observeOnMain(onNext: { [weak self] selectedMenu in
            guard let self = self                 else { return }
            guard let selectedMenu = selectedMenu else { return }
            
            let title = selectedMenu.title == "default" ? "선택 안함" : selectedMenu.title
            self.selectedLabel.text = title
            self._delegate?.addTodoDropdownTableViewCell(self, didSelectedJourney: selectedMenu)
        }).disposed(by: self.disposeBag)
    }
    
    private func bindButton() {
        self.dropdownButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self    = self else { return }
                guard let expaned = try? self.viewModel.isExpanded.value() else { return }
                
                self.viewModel.isExpanded.onNext(!expaned)
            }).disposed(by: self.disposeBag)
        
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
            }).disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.viewModel.journeyListRelay.bind(to: self.tableView.rx.items) { tableView, index, item in
            let indexPath = IndexPath(row: index, section: 0)
            let cell      = tableView.dequeueReusableCell(cell: DropdownItemTableViewCell.self, forIndexPath: indexPath)
            
            guard let dropdownCell = cell else { return UITableViewCell() }
            dropdownCell.configure(by: item)
            return dropdownCell
        }.disposed(by: self.disposeBag)
    }
    
    private static let duration: TimeInterval       = 0.2
    private static let screenRatio: CGFloat         = DeviceInfo.screenWidth / 375
    private static let menuCellHeight: CGFloat      = 56 * screenRatio
    private static let selectBorderColor: UIColor   = UIColor.mainSky
    
    private weak var _delegate: AddTodoDropdownTableViewCellDelegate?
    
    private var viewModel  = AddTodoDropdownViewModel()
    private var disposeBag = DisposeBag()
    
    @IBOutlet private weak var containerView: UIStackView!
    @IBOutlet private weak var selectedLabel: UILabel!
    @IBOutlet private weak var dropdownButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
}

extension AddTodoDropdownTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).menuCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedMenu = self.viewModel.journeyListRelay.value[safe: indexPath.row] else { return }
        self.viewModel.isExpanded.onNext(false)
        self.viewModel.updateSelectedMenu(selectedMenu)
        
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
}
