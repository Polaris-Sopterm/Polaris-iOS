//
//  TodoDateTodoTVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/15.
//

import UIKit
import RxSwift
import RxCocoa

class TodoDateTVC: UITableViewCell {
    
    @IBOutlet weak var fixImageView: UIImageView!
    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var todoSubLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    let disposebag = DisposeBag()
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setUIs(todoModel: TodoModel){
        
        
        if todoModel.checked {
            checkButton.setImage(UIImage(named: "btnCheck"), for: .normal)
        }
        else {
            checkButton.setImage(UIImage(named: "btnUncheck"), for: .normal)
        }
        if todoModel.fixed {
            fixImageView.alpha = 1
        }
        else {
            fixImageView.alpha = 0
        }
        todoTitleLabel.text = todoModel.todoTitle
        todoSubLabel.text = todoModel.todoSubtitle
    }
    
    func bindViewModel<O>(viewModel: TodoDateTVCViewModel, buttonClicked: O) where O: ObserverType, O.Element == IndexPath  {
        checkButton.rx.tap
            .map{viewModel.id}
            .flatMapLatest{
                return Observable.of($0)
            }
            .bind(to: buttonClicked)
            .disposed(by: disposebag)
            

    }
    
    
}




