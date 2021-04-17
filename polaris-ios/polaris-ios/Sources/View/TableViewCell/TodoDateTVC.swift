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
    
    var disposebag = DisposeBag()
    var tvcViewModel: TodoDateTVCViewModel?
    var checkButtonClicked = PublishSubject<IndexPath>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    override func prepareForReuse() {
        disposebag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setUIs(todoModel: TodoModel){
        
        
        if todoModel.checked {
            checkButton.setImage(UIImage(named: "btnCheck"), for: .normal)
            
            todoTitleLabel.textColor = UIColor(red: 198, green: 198, blue: 221, alpha: 1.0)
            todoSubLabel.textColor = UIColor(red: 198, green: 198, blue: 221, alpha: 1.0)
        }
        else {
            checkButton.setImage(UIImage(named: "btnUncheck"), for: .normal)
            todoTitleLabel.textColor = UIColor(red: 64, green: 64, blue: 140, alpha: 1.0)
            todoSubLabel.textColor = UIColor(red: 64, green: 64, blue: 140, alpha: 1.0)
        }
        if todoModel.fixed {
            fixImageView.alpha = 1
        }
        else {
            fixImageView.alpha = 0
        }
        todoTitleLabel.text = todoModel.todoTitle
        todoSubLabel.text = todoModel.todoSubtitle
        lineView.backgroundColor = UIColor(red: 233, green: 233, blue: 246, alpha: 1.0)
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




