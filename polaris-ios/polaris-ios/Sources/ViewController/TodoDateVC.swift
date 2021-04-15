//
//  TodoDateVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/15.
//

import UIKit
import RxSwift
import RxCocoa


class TodoDateVC: UIViewController {
    
    @IBOutlet weak var wholeTV: UITableView!
    
    let viewModel = TodoDateViewModel()
    let disposeBag = DisposeBag()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wholeTV.delegate = self
        wholeTV.dataSource = self
        wholeTV.registerCell(cell: TodoDateTVC.self)
        
        
    }
    
    
    private func bindOutput(){
        viewModel.todoFetchFinished
            .subscribe(onNext: { error in
                print("error")
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
}


extension TodoDateVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoDateTVC", for: indexPath) as! TodoDateTVC
        cell.setUIs(todoModel: viewModel.todos[indexPath.section][indexPath.item])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.todos[section].count
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.dates.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //        let headerView = TodoDateHeaderView.instanceFromNib()
        let headerView: TodoDateHeaderView? = UIView.fromNib()
        return headerView
    }
    
    
}

extension TodoDateVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 49+58
    }
}
