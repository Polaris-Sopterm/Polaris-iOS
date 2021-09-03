//
//  MainTodoTVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/25.
//

import UIKit
import RxSwift
import RxCocoa

class MainTodoTVC: UITableViewCell {
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var fixedImage: UIImageView!
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkButtonImage: UIImageView!
    private var disposeBag = DisposeBag()
    
    var tvcModel: TodoModel? {
        didSet{
            self.titleLabel.text = self.tvcModel?.title
            if let model = self.tvcModel {
                self.setUIs(todoModel: model)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let model = self.tvcModel {
            self.setUIs(todoModel: model)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        if let model = self.tvcModel {
            self.setUIs(todoModel: model)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func setUIs(todoModel: TodoModel){
        self.backgroundColor = .clear
        self.titleLabel.textColor = .white
        self.subLabel.textColor = .white
        self.titleLabel.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        self.subLabel.font = UIFont.systemFont(ofSize: 11,weight: .medium)
        
        if todoModel.isDone != nil {
            self.checkButton.setImage(UIImage(named: ImageName.btnCheck), for: .normal)
            self.titleLabel.alpha = 0.35
            self.subLabel.alpha = 0.35
            
        } else {
            self.checkButtonImage.image = UIImage(named: ImageName.btnUncheck)
            self.titleLabel.alpha = 1.0
            self.subLabel.alpha = 1.0
        }
        
        if todoModel.isTop == true {
            self.fixedImage.alpha = 1
        } else {
            self.fixedImage.alpha = 0
        }
        
        self.titleLabel.text = todoModel.title
        self.subLabel.text = todoModel.date
        self.lineView.backgroundColor = .inactivePurple
    }
    
    @IBAction func checkButtonAction(_ sender: Any) {
        
        guard let idx = tvcModel?.idx else { return }
        if let _ = tvcModel?.isDone {
            let todoEditAPI = TodoAPI.editTodo(idx: idx, isDone: false)
            NetworkManager.request(apiType: todoEditAPI).subscribe(onSuccess: { [weak self] (responseModel: TodoModel) in
                guard let self = self else { return }
                
                self.tvcModel = TodoModel(idx: responseModel.idx, title: responseModel.title, isTop: responseModel.isTop, isDone: responseModel.isDone, date: responseModel.date, createdAt: responseModel.createdAt, journey: responseModel.journey)
            }).disposed(by: self.disposeBag)
        }
        else {
            let todoEditAPI = TodoAPI.editTodo(idx: idx, isDone: true)
            NetworkManager.request(apiType: todoEditAPI).subscribe(onSuccess: { [weak self] (responseModel: TodoModel) in
                guard let self = self else { return }
                self.tvcModel = TodoModel(idx: responseModel.idx, title: responseModel.title, isTop: responseModel.isTop, isDone: responseModel.isDone, date: responseModel.date, createdAt: responseModel.createdAt, journey: responseModel.journey)
            }).disposed(by: self.disposeBag)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkButton"), object: nil)
        
    }
    
    
    
    
}

