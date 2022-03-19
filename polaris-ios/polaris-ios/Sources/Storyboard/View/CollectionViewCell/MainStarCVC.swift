//
//  MainStarCVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import UIKit

class MainStarCVC: UICollectionViewCell {
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var labelBackground: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var starPositionConstraint: NSLayoutConstraint!
    
    var cvcViewModel: MainStarCVCViewModel? {
        didSet{
            setStar(image: UIImage(named: self.cvcViewModel!.starImgName)!, category: self.cvcViewModel!.starModel.starName, starHeight: self.cvcViewModel!.starHeight)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUIs()
        
    }
    
    func setUIs(){
        self.categoryLabel.textColor = .white
        self.categoryLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 13)
        self.labelBackground.backgroundColor = .darkBlue10
        self.labelBackground.makeRoundCorner(radius: 10)
    }
    
    func setStar(image: UIImage, category: String,starHeight: CGFloat) {
        self.starImage.image = image
        self.categoryLabel.text = category
        self.starPositionConstraint.constant = starHeight
        
    }

}
