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
    
    
    let checkButtonClicked = PublishSubject<IndexPath>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wholeTV.delegate = self
        wholeTV.dataSource = self
        wholeTV.registerCell(cell: TodoDateTVC.self)
        bindOutput()
        bindViewModel()
        
    }

    private func bindViewModel(){
      
        let input = TodoDateViewModel.Input(checkButtonClicked: checkButtonClicked)
        let output = viewModel.connect(input: input)
        

            
        
    }
    
    
    private func bindOutput(){

        viewModel.todoFetchFinished
            .flatMapLatest{
                return Observable.of($0)
            }
            .subscribe(onNext: { [weak self] _ in
                print("called")
                self?.wholeTV.reloadData()
                
                
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
}


extension TodoDateVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoDateTVC", for: indexPath) as! TodoDateTVC
        
        let tvcViewModel = TodoDateTVCViewModel(id: indexPath, todoModel: viewModel.todoDateModels[indexPath.section].todos[indexPath.row])
        
        cell.bindViewModel(viewModel: tvcViewModel, buttonClicked: checkButtonClicked.asObserver())
        cell.setUIs(todoModel: tvcViewModel.todoModel)

        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.todoDateModels[section].todos.count
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.todoDateModels.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: TodoDateHeaderView? = UIView.fromNib()
        headerView?.setDate(date: viewModel.todoDateModels[section].date)
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
