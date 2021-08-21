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
        self.registerCell()
        self.setupTableView()
        self.bindButtons()
        self.bindEnableButton()
        self.observeViewModel()
        self.setupCurrentTodo()
    }
    
    // MARK: - Set Up
    func setAddOptions(_ options: AddOptions) {
        self.viewModel.setViewModel(by: options)
    }
    
    func setAddTodoDate(_ date: Date) {
        self.viewModel.setAddTodoDate(date)
    }
    
    func setEditTodo(_ todo: TodoDayPerModel) {
        self.viewModel.setEditTodoModel(todo)
    }
    
    private func setupTitleLabel() {
        if self.viewModel.currentAddOption == .perDayAddTodo {
            guard let date = self.viewModel.currentDate else { return }
            self.titleLabel.text = date.convertToString(using: "M월 d일") + "의 할 일"
        } else if self.viewModel.currentAddOption == .perJourneyAddTodo {
            self.titleLabel.text = "폴라리스의 할 일"
        } else if self.viewModel.currentAddOption == .addJourney {
            self.titleLabel.text = "여정 추가하기"
        } else {
            self.titleLabel.text = "일정 수정"
        }
    }
    
    private func setupCurrentTodo() {
        guard self.viewModel.currentAddOption == .edittedTodo else { return }
        guard let todoModel = self.viewModel.todoDayModel     else { return }
        
        for index in 0..<self.viewModel.addOptionCount {
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = self.tableView.cellForRow(at: indexPath) else { continue }
            
            if let addTextCell = cell as? AddTodoTextTableViewCell {
                addTextCell.updateAddText(todoModel.title ?? "")
            } else if let dropdownCell = cell as? AddTodoDropdownTableViewCell {
                dropdownCell.updateSelectedJourney(todoModel.journey ?? JourneyTitleModel(idx: nil, title: "default",
                                                                                          year: nil, month: nil,
                                                                                          weekNo: nil, userIdx: nil))
            } else if let selectDayCell = cell as? AddTodoDayTableViewCell,
                      let selectDate = todoModel.date?.convertToDate()?.normalizedDate {
                selectDayCell.updateSelectDate(selectDate)
            } else if let fixOnTopCell = cell as? AddTodoFixOnTopTableViewCell {
                fixOnTopCell.updateFix(todoModel.isTop ?? false)
            }
        }
    }
    
    private func setupLoadingIndicator() {
        self.view.addSubview(self.loadingIndicatorView)
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        let screenRatio: CGFloat  = (DeviceInfo.screenWidth / 375)
        let buttonHeight: CGFloat = 54 * screenRatio
        let bottomInset: CGFloat  = 37 + buttonHeight + 20
        self.tableView.contentInset        = UIEdgeInsets(top: 20, left: 0, bottom: bottomInset, right: 0)
        self.tableView.allowsSelection     = false
        self.tableView.separatorStyle      = .none
        self.tableView.keyboardDismissMode = .onDrag
        
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.viewModel.addListTypes
            .bind(to: self.tableView.rx.items) { [weak self] tableView, index, item in
                guard let self = self else { return UITableViewCell() }
                
                let indexPath = IndexPath(row: index, section: 0)
                let cell      = tableView.dequeueReusableCell(cell: item, forIndexPath: indexPath)
                
                guard let addTodoCell = cell as? AddTodoTableViewCellProtocol else { return UITableViewCell() }
                guard let currentAddOption = self.viewModel.currentAddOption  else { return UITableViewCell() }
                
                addTodoCell.delegate = self
                addTodoCell.configure(by: currentAddOption, date: self.viewModel.currentDate)
                return addTodoCell
            }
            .disposed(by: self.disposeBag)
    }
    
    private func registerCell() {
        guard let cellTypes = try? self.viewModel.addListTypes.value() else { return }
        cellTypes.forEach { cellType in self.tableView.registerCell(cell: cellType) }
    }
    
    // MARK: - Bind
    private func bindButtons() {
        self.cancelButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismissWithAnimation()
        }).disposed(by: self.disposeBag)
        
        self.addButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.requestAddTodo()
        }).disposed(by: self.disposeBag)
    }
    
    private func bindEnableButton() {
        self.viewModel.addEnableFlagSubject.subscribe(onNext: { [weak self] isEnable in
            guard let self = self else { return }
            if isEnable == true { self.addButton.enable = true }
            else                { self.addButton.enable = false }
        }).disposed(by: self.disposeBag)
    }

    private func observeViewModel() {
        self.viewModel.completeAddTodoSubject.observeOnMain(onNext: { [weak self] in
            guard let self = self                                     else { return }
            guard let currentOption = self.viewModel.currentAddOption else { return }
            self.delegate?.addTodoViewController(self, didCompleteAddOption: currentOption)
            self.dismissWithAnimation()
            
            PolarisToastManager.shared.showToast(with: "할 일이 추가되었어요.")
        }).disposed(by: self.disposeBag)
        
        self.viewModel.loadingSubject.observeOnMain(onNext: { [weak self] isLoading in
            self?.addButton.isUserInteractionEnabled = isLoading == false
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

    private let disposeBag = DisposeBag()
    
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
        static let edittedTodo: AddOptions       = [.addText, .dropdownMenu, .selectDay, .fixOnTop]
        
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
