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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Bind
    private func bindButton() {
        self.cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.halfModalViewWillDisappear()
                print("Here?")
            })
            .disposed(by: self.disposeBag)
        
        self.addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.halfModalViewWillDisappear()
            })
            .disposed(by: self.disposeBag)
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: AddButton!
    private var disposeBag = DisposeBag()
}
