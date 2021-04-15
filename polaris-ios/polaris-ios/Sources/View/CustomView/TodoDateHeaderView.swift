//
//  TodoDateHeaderView.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/15.
//

import UIKit


class TodoDateHeaderView: UIView {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        self.addSubview(view)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //    required init?(coder aDecoder: NSCoder) {
    //        super.init(coder: aDecoder)
    //
    //
    //    }
    
    
    
    func setDate(date: String){
        dateLabel.text = date
    }
    
    
    
}
