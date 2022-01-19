//
//  TodoDateHeaderView.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/15.
//

import UIKit

class TodoDateHeaderView: UICollectionReusableView {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.makeRounded(cornerRadius: 20)
    }
    
    func setDate(date: String) {
        self.dateLabel.text = date
    }
    
}
