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
    var tvcViewModel: TodoDateTVCViewModel?{
        didSet{
            self.setUIs(todoModel: tvcViewModel!.todoModel)
        }
    }
    var checkButtonClicked = PublishSubject<IndexPath>()
    
    override func awakeFromNib() {
        self.backgroundColor = .clear
        super.awakeFromNib()
       
    }
    override func prepareForReuse() {
        self.disposebag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setUIs(todoModel: TodoModel){
        
        
        if todoModel.checked {
            self.checkButton.setImage(UIImage(named: ImageName.btnCheck), for: .normal)
            
            self.todoTitleLabel.textColor = .inactiveTextPurple
            self.todoSubLabel.textColor = .inactiveTextPurple
        }
        else {
            self.checkButton.setImage(UIImage(named: ImageName.btnUncheck), for: .normal)
            self.todoTitleLabel.textColor = .maintext
            self.todoSubLabel.textColor = .maintext
        }
        if todoModel.fixed {
            self.fixImageView.alpha = 1
        }
        else {
            self.fixImageView.alpha = 0
        }
        self.todoTitleLabel.text = todoModel.todoTitle
        self.todoSubLabel.text = todoModel.todoSubtitle
        self.lineView.backgroundColor = .inactivePurple
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




