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
        self.bindButton()
        self.registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Set Up
    func setupAddOptions(_ options: AddOptions) {
        self.addOptions = options
    }
    
    private func registerCell() {
        self.addOptions.addCellType.forEach { cellType in
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
    
    private var addOptions: AddOptions = .perDayAddTodo
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: AddButton!
    private var disposeBag = DisposeBag()
}

extension AddTodoVC {
    struct AddOptions: OptionSet {
        let rawValue: Int
        
        static let addText          = AddOptions(rawValue: 1 << 0)
        static let selectDay        = AddOptions(rawValue: 1 << 1)
        static let fixOnTop         = AddOptions(rawValue: 1 << 2)
        static let dropdownMenu     = AddOptions(rawValue: 1 << 3)
        
        static let perDayAddTodo: AddOptions    = [.addText, dropdownMenu, fixOnTop]
        static let perTravisAddTodo: AddOptions = [.addText, .selectDay, .fixOnTop]
        
        var addCellType: [AddTodoTableViewCellProtocol.Type] {
            var cellTypes = [AddTodoTableViewCellProtocol.Type]()
            if self.contains(.addText) { cellTypes.append(AddTodoTextTableViewCell.self) }
            return cellTypes
        }
    }
}
