//
//  LookBackFirstStarCollectionViewCell.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/12/26.
//

import UIKit

class LookBackFirstStarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var starNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setLabel()
        // Initialization code
    }
    
    private func setLabel() {
        self.starNameLabel.textColor = .white
        self.starNameLabel.font = UIFont.systemFont(ofSize: 13)
    }
    
    func setStar(imageName: String, starName: String) {
        self.starImageView.image = UIImage(named: imageName)
        self.starNameLabel.text = starName
    }

}
