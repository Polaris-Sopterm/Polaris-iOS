//
//  MainTodoTVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/25.
//

import UIKit
import RxSwift
import RxCocoa

protocol MainTodoTableViewCellDelegate: AnyObject {
    func mainTodoTableViewCell(_ cell: MainTodoTVC, didTapDone todo: TodoModel)
}

class MainTodoTVC: UITableViewCell {
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fixedImage: UIImageView!
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkButtonImage: UIImageView!
    
    weak var delegate: MainTodoTableViewCellDelegate?
    
    var todoModel: TodoModel? {
        didSet{
            self.titleLabel.text = self.todoModel?.title
            
            guard let model = self.todoModel else { return }
            self.setUIs(todoModel: model)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let model = self.todoModel {
            self.setUIs(todoModel: model)
        }
    }
    
    func setUIs(todoModel: TodoModel){
        self.backgroundColor = .clear
        self.titleLabel.textColor = .white
        self.dateLabel.textColor = .white
        self.titleLabel.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        self.dateLabel.font = UIFont.systemFont(ofSize: 11,weight: .medium)
        
        if todoModel.isDone != nil {
            self.checkButtonImage.image = UIImage(named: ImageName.btnCheck)
            self.titleLabel.alpha = 0.35
            self.dateLabel.alpha = 0.35
        } else {
            self.checkButtonImage.image = UIImage(named: ImageName.btnUncheck)
            self.titleLabel.alpha = 1.0
            self.dateLabel.alpha = 1.0
        }
        
        if todoModel.isTop == true {
            self.fixedImage.alpha = 1
        } else {
            self.fixedImage.alpha = 0
        }
        
        self.titleLabel.text = todoModel.title
        self.dateLabel.text = todoModel.date?.convertToDate()?.convertToString(using: "M월 d일 EEEE")
        self.lineView.backgroundColor = .inactivePurple
    }
    
    @IBAction func checkButtonAction(_ sender: Any) {
        guard let todoModel = self.todoModel else { return }
        self.delegate?.mainTodoTableViewCell(self, didTapDone: todoModel)
    }
    
    private let disposeBag = DisposeBag()
    
}

