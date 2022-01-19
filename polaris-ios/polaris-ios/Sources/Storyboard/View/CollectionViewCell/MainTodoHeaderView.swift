//
//  MainTodoHeaderView.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/26.
//

import UIKit

class MainTodoHeaderView: UICollectionReusableView {

    @IBOutlet weak var titleContainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var addButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUIs()
    }
    
    func setUIs(){
        self.titleContainView.backgroundColor = .white60
        self.titleContainView.setBorder(borderColor: .white, borderWidth: 1.0)
        self.titleLabel.font = UIFont.systemFont(ofSize: 13,weight: .bold)
        self.titleLabel.textColor = .white
        
        self.nowLabel.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        self.nowLabel.textColor = .white
        
        
        
    }
    
}
