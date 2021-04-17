//
//  TodoDateTodayHeaderView.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/17.
//

import UIKit

class TodoDateTodayHeaderView: UICollectionReusableView {

    @IBOutlet weak var upperButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var upperButtonLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUIs()
        
    }
    
    func setUIs(){
        self.containerView.backgroundColor
            = UIColor(red: 229, green: 248, blue: 252, alpha: 1.0)
        self.dateLabel.textColor = UIColor(red: 104, green: 199, blue: 220, alpha: 1.0)
        self.upperButtonLabel.textColor = UIColor(red: 64, green: 64, blue: 140, alpha: 1.0)
        self.containerView.makeRounded(cornerRadius: 20)
    }
    
    
    func setDate(date: String) {
        self.dateLabel.text = date
    }
    
}
