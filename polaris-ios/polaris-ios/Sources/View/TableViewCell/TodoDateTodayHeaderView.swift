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
            = .inactiveSky
        self.dateLabel.textColor = .textSky
        self.upperButtonLabel.textColor = .maintext
        self.containerView.makeRounded(cornerRadius: 20)
    }
    
    
    func setDate(date: String) {
        self.dateLabel.text = date
    }
    
}
