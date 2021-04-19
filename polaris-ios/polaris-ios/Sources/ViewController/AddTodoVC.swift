//
//  AddTodoVC.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit
import RxCocoa
import RxSwift

class AddTodoVC: HalfModalVC {
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupTableView()
        self.registerCell()
        self.bindButton()
        self.bindTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Set Up
    func setupAddOptions(_ options: AddOptions) {
        self.addOptions = options
    }
    
    private func setupTableView() {
        self.tableView.contentInset     = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.tableView.allowsSelection  = false
        self.tableView.separatorStyle   = .none
    }
    
    private func registerCell() {
        self.addOptions.addCellTypes.forEach { cellType in
            self.tableView.registerCell(cell: cellType)
        }
    }
    
    // MARK: - Bind
    private func bindButton() {
        self.cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.halfModalViewWillDisappear()
            })
            .disposed(by: self.disposeBag)
        
        self.addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.halfModalViewWillDisappear()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.viewModel.addListTypes
            .bind(to: self.tableView.rx.items) { tableView, index, item in
                guard let addTodoCell = tableView.dequeueReusableCell(cell: item, forIndexPath: IndexPath(row: index, section: 0)) as? AddTodoTableViewCellProtocol else { return UITableViewCell() }
                addTodoCell.configure(by: self.addOptions)
                return addTodoCell
            }
            .disposed(by: self.disposeBag)
    }
    
    private var addOptions: AddOptions = .perDayAddTodo {
        didSet { self.viewModel.addListTypes.onNext(self.addOptions.addCellTypes) }
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: AddButton!
    
    private var viewModel   = AddTodoViewModel()
    private var disposeBag  = DisposeBag()
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
        
        static let perDayAddTodo: AddOptions     = [.addText, dropdownMenu, fixOnTop]
        static let perJourneyAddTodo: AddOptions = [.addText, .selectDay, .fixOnTop]
        static let addJourney: AddOptions        = []
        
        var addCellTypes: [AddTodoTableViewCellProtocol.Type] {
            var cellTypes = [AddTodoTableViewCellProtocol.Type]()
            if self.contains(.addText)      { cellTypes.append(AddTodoTextTableViewCell.self) }
            if self.contains(.dropdownMenu) { cellTypes.append(AddTodoDropdownTableViewCell.self) }
            if self.contains(.fixOnTop)     { cellTypes.append(AddTodoFixOnTopTableViewCell.self) }
            return cellTypes
        }
    }
}
