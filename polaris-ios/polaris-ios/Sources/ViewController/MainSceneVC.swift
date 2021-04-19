//
//  MainSceneVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import UIKit
import RxSwift
import RxCocoa

class MainSceneVC: UIViewController {

    @IBOutlet weak var wholeTV: UITableView!
    
    
    let viewModel = MainSceneViewModel()
    var starTVCViewModel: MainStarTVCViewModel?
    var dataDriver: Driver<[MainStarCVCViewModel]>?
    var starList: [MainStarCVCViewModel] = [] {
        didSet{
            self.wholeTV.reloadData()
        }
    }
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIs()
        self.bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    func setUIs(){
        self.wholeTV.delegate = self
        self.wholeTV.dataSource = self
        self.wholeTV.registerCell(cell: MainStarTVC.self)
        self.wholeTV.backgroundColor = .clear
    }
    
    private func bindViewModel(){
        let input = MainSceneViewModel.Input()
        let output = viewModel.connect(input: input)

        output.starList.subscribe(onNext: { item in
            self.starList = item
            
        })
        .disposed(by: disposeBag)


    }


}

extension MainSceneVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: MainStarTVC.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MainStarTVC
        
        cell.setTitle(stars: 1)
        cell.starList = self.starList

        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension MainSceneVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
}
