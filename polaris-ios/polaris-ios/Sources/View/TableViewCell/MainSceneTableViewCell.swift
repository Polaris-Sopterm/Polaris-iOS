//
//  MainSceneTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/17.
//

import UIKit

final class MainSceneTableViewCell: MainTableViewCell {
    
    override static var cellHeight: CGFloat { return DeviceInfo.screenHeight }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupDimView()
    }
    
    func updateDimView(alpha: CGFloat) {
        self.dimView.alpha = alpha
        if alpha == 0 { self.dimView.isHidden = true }
        else          { self.dimView.isHidden = false }
    }
    
    private func setupDimView() {
        self.dimView.frame           = CGRect(x: 0, y: 0,
                                              width: DeviceInfo.screenWidth, height: type(of: self).cellHeight)
        self.dimView.backgroundColor = .black
        self.dimView.alpha           = 0.0
        self.contentView.addSubview(self.dimView)
    }
    
    private var dimView: UIView = UIView(frame: .zero)

}
