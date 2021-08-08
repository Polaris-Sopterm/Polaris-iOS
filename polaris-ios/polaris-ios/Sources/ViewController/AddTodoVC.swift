//
//  AddTodoVC.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit
import RxCocoa
import RxSwift

protocol AddTodoViewControllerDelegate: AnyObject {
    func addTodoViewController(_ viewController: AddTodoVC, didCompleteAddOption option: AddTodoVC.AddOptions)
}

class AddTodoVC: HalfModalVC {
    
    weak var delegate: AddTodoViewControllerDelegate?
    
    let viewModel = AddTodoViewModel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.halfModalView = self.addTodoHalfModalView
        self.setupLoadingIndicator()
        self.setupTitleLabel()
        self.setupTableView()
        self.registerCell()
        self.bindButtons()
        self.bindEnableButton()
        self.bindTableView()
        self.observeViewModel()
    }
    
    // MARK: - Set Up
    func setAddOptions(_ options: AddOptions, _ addTodoDate: Date? = nil) {
        self.viewModel.setViewModel(by: options)
    }
    
    func setAddTodoDate(_ date: Date) {
        self.viewModel.setAddTodoDate(date)
    }
    
    private func setupTitleLabel() {
        if self.viewModel.currentAddOption == .perDayAddTodo {
            guard let date = self.viewModel.addTodoDate else { return }
            self.titleLabel.text = date.convertToString(using: "M월 d일") + "의 할 일"
        } else if self.viewModel.currentAddOption == .perJourneyAddTodo {
            self.titleLabel.text = "폴라리스의 할 일"
        } else {
            self.titleLabel.text = "여정 추가하기"
        }
    }
    
    private func setupLoadingIndicator() {
        self.view.addSubview(self.loadingIndicatorView)
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        self.tableView.contentInset        = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.tableView.allowsSelection     = false
        self.tableView.separatorStyle      = .none
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    private func registerCell() {
        guard let cellTypes = try? self.viewModel.addListTypes.value() else { return }
        cellTypes.forEach { cellType in self.tableView.registerCell(cell: cellType) }
    }
    
    // MARK: - Bind
    private func bindButtons() {
        self.cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismissWithAnimation()
            })
            .disposed(by: self.disposeBag)
        
        self.addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.requestAddTodo()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindEnableButton() {
        self.viewModel.addEnableFlagSubject
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isEnable in
                guard let self = self else { return }
                if isEnable == true { self.addButton.enable = true }
                else                { self.addButton.enable = false }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.viewModel.addListTypes
            .bind(to: self.tableView.rx.items) { tableView, index, item in
                guard let addTodoCell      = tableView.dequeueReusableCell(cell: item, forIndexPath: IndexPath(row: index, section: 0)) as? AddTodoTableViewCellProtocol,
                      let currentAddOption = self.viewModel.currentAddOption else { return UITableViewCell() }
                
                addTodoCell.delegate = self
                addTodoCell.configure(by: currentAddOption)
                return addTodoCell
            }
            .disposed(by: self.disposeBag)
    }
    
    private func observeViewModel() {
        self.viewModel.completeAddTodoSubject.observeOnMain(onNext: { [weak self] in
            guard let self = self                                     else { return }
            guard let currentOption = self.viewModel.currentAddOption else { return }
            self.delegate?.addTodoViewController(self, didCompleteAddOption: currentOption)
            self.dismissWithAnimation()
        }).disposed(by: self.disposeBag)
        
        self.viewModel.loadingSubject.observeOnMain(onNext: { [weak self] isLoading in
            isLoading ? self?.startLoadingIndicator() : self?.stopLoadingIndicator()
        }).disposed(by: self.disposeBag)
    }
    
    private func startLoadingIndicator() {
        self.loadingIndicatorView.isHidden = false
        self.loadingIndicatorView.startAnimating()
    }
    
    private func stopLoadingIndicator() {
        self.loadingIndicatorView.isHidden = true
        self.loadingIndicatorView.stopAnimating()
    }
    
    private let disposeBag  = DisposeBag()
    
    private let loadingIndicatorView = UIActivityIndicatorView(style: .medium)
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var addButton: PolarisButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addTodoHalfModalView: UIView!
    
}

extension AddTodoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellHeight = try? self.viewModel.addListTypes.value()[indexPath.row].cellHeight else { return 0 }
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellHeight = try? self.viewModel.addListTypes.value()[indexPath.row].cellHeight else { return UITableView.automaticDimension }
        return cellHeight
    }
}

extension AddTodoVC {
    struct AddOptions: OptionSet {
        let rawValue: Int
        
        static let addText          = AddOptions(rawValue: 1 << 0)
        static let selectDay        = AddOptions(rawValue: 1 << 1)
        static let fixOnTop         = AddOptions(rawValue: 1 << 2)
        static let dropdownMenu     = AddOptions(rawValue: 1 << 3)
        static let selectStar       = AddOptions(rawValue: 1 << 4)
        
        static let perDayAddTodo: AddOptions     = [.addText, dropdownMenu, fixOnTop]
        static let perJourneyAddTodo: AddOptions = [.addText, .selectDay, .fixOnTop]
        static let addJourney: AddOptions        = [.addText, .selectStar]
        
        var addCellTypes: [AddTodoTableViewCellProtocol.Type] {
            var cellTypes = [AddTodoTableViewCellProtocol.Type]()
            if self.contains(.addText)       { cellTypes.append(AddTodoTextTableViewCell.self) }
            if self.contains(.dropdownMenu)  { cellTypes.append(AddTodoDropdownTableViewCell.self) }
            if self.contains(.selectDay)     { cellTypes.append(AddTodoDayTableViewCell.self) }
            if self.contains(.fixOnTop)      { cellTypes.append(AddTodoFixOnTopTableViewCell.self) }
            if self.contains(.selectStar)    { cellTypes.append(AddTodoSelectStarTableViewCell.self) }
            return cellTypes
        }
        
        var menuKey: String? {
            if self == .addText           { return "ADD_TEXT" }
            else if self == .selectDay    { return "SELECT_DAY" }
            else if self == .fixOnTop     { return "FIX_ON_TOP" }
            else if self == .dropdownMenu { return "DROPDOWN_MENU" }
            else if self == .selectStar   { return "SELECT_STAR" }
            else                          { return nil }
        }
    }
}
