//
//  TodoDateHeaderView.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/15.
//

import UIKit

class TodoDateHeaderView: UICollectionReusableView {
    
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.makeRounded(cornerRadius: 20)
    }
    
}
