//
//  MainTodoTVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/25.
//

import UIKit

class MainTodoTVC: UITableViewCell {
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var fixedImage: UIImageView!
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkButtonImage: UIImageView!
    
    var tvcViewModel: MainTodoTVCViewModel?{
        didSet{

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        
        if todoModel.checked {
            self.checkButton.setImage(UIImage(named: ImageName.btnCheck), for: .normal)
            self.titleLabel.alpha = 0.35
            self.subLabel.alpha = 0.35
           
        }
        else {
            self.checkButton.setImage(UIImage(named: ImageName.btnUncheck), for: .normal)
        }
        if todoModel.fixed {
            self.fixedImage.alpha = 1
        }
        else {
            self.fixedImage.alpha = 0
        }
        self.titleLabel.text = todoModel.todoTitle
        self.subLabel.text = todoModel.todoSubtitle
        self.lineView.backgroundColor = .inactivePurple
    }
    
    
}

