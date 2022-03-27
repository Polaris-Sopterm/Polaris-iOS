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
    func addTodoViewController(_ viewController: AddTodoVC, didCompleteAddMode mode: AddTodoVC.AddMode)
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
    }
    
    // MARK: - Set Up
    func setAddMode(_ mode: AddMode) {
        self.viewModel.setAddMode(mode)
    }
    
    private func setupTitleLabel() {
        guard let mode = self.viewModel.addMode else { return }
        switch mode {
        case .addDayTodo(let date):
            self.titleLabel.text = date.convertToString(using: "M월 d일") + "의 할 일"
            self.addButton.setTitle("추가하기", for: .normal)
            
        case .addJourneyTodo(let journey):
            let journeyTitle = journey.title ?? "default"
            self.titleLabel.text = journeyTitle == "default" ? "여정이 없는 할 일" : String(format: "%@의 할 일", journeyTitle)
            self.addButton.setTitle("추가하기", for: .normal)
            
        case .addJourney:
            self.titleLabel.text = "여정 추가하기"
            self.addButton.setTitle("추가하기", for: .normal)
            
        case .editTodo:
            self.titleLabel.text = "일정 수정하기"
            self.addButton.setTitle("수정하기", for: .normal)
            
        case .editJourney:
            self.titleLabel.text = "여정 수정하기"
            self.addButton.setTitle("수정하기", for: .normal)
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
                guard let currentAddMode = self.viewModel.addMode             else { return UITableViewCell() }
                
                addTodoCell.delegate = self
                addTodoCell.configure(by: currentAddMode, date: self.viewModel.currentDate)
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
        
        self.addButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.occur(viewEvent: .didTapAddButton)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindEnableButton() {
        self.viewModel.addEnableFlagSubject.subscribe(onNext: { [weak self] isEnable in
            guard let self = self else { return }
            if isEnable == true { self.addButton.enable = true }
            else                { self.addButton.enable = false }
        }).disposed(by: self.disposeBag)
    }

    private func observeViewModel() {
        self.viewModel.completeRequestSubject.observeOnMain(onNext: { [weak self] in
            guard let self = self                                     else { return }
            guard let currentMode = self.viewModel.addMode            else { return }
            
            self.delegate?.addTodoViewController(self, didCompleteAddMode: currentMode)
            self.dismissWithAnimation()
            
            switch currentMode {
            case .addDayTodo, .addJourneyTodo:
                PolarisToastManager.shared.showToast(with: "할 일이 추가되었어요.")
                
            case .addJourney:
                PolarisToastManager.shared.showToast(with: "여정이 추가되었어요.")
                
            default:
                break
            }
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
        
        static let addText       = AddOptions(rawValue: 1 << 0)
        static let selectDay     = AddOptions(rawValue: 1 << 1)
        static let fixOnTop      = AddOptions(rawValue: 1 << 2)
        static let dropdownMenu  = AddOptions(rawValue: 1 << 3)
        static let selectJourney = AddOptions(rawValue: 1 << 4)
        static let deleteJourney = AddOptions(rawValue: 1 << 5)
        
        static let perDayAddTodo: AddOptions     = [.addText, dropdownMenu, fixOnTop]
        static let perJourneyAddTodo: AddOptions = [.addText, .selectDay, .fixOnTop]
        static let addJourney: AddOptions        = [.addText, .selectJourney]
        static let edittedTodo: AddOptions       = [.addText, .dropdownMenu, .selectDay, .fixOnTop]
        static let edittedJourney: AddOptions    = [.addText, .selectJourney, .deleteJourney]
        
        var addCellTypes: [AddTodoTableViewCellProtocol.Type] {
            var cellTypes = [AddTodoTableViewCellProtocol.Type]()
            if self.contains(.addText)       { cellTypes.append(AddTodoTextTableViewCell.self)          }
            if self.contains(.dropdownMenu)  { cellTypes.append(AddTodoDropdownTableViewCell.self)      }
            if self.contains(.selectDay)     { cellTypes.append(AddTodoDayTableViewCell.self)           }
            if self.contains(.fixOnTop)      { cellTypes.append(AddTodoFixOnTopTableViewCell.self)      }
            if self.contains(.selectJourney) { cellTypes.append(AddTodoSelectStarTableViewCell.self)    }
            if self.contains(.deleteJourney) { cellTypes.append(AddTodoDeleteJourneyTableViewCell.self) }
            return cellTypes
        }
    }
    
    enum AddMode {
        case addDayTodo(Date)
        case addJourneyTodo(WeekJourneyModel)
        case addJourney(PolarisDate)
        case editTodo(TodoModel)
        case editJourney(WeekJourneyModel)
        
        var addOptions: AddOptions {
            switch self {
            case .addDayTodo:       return .perDayAddTodo
            case .addJourneyTodo:   return .perJourneyAddTodo
            case .addJourney:       return .addJourney
            case .editTodo:         return .edittedTodo
            case .editJourney:      return .edittedJourney
            }
        }
    }
    
}
