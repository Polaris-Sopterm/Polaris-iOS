//
//  PolarisStarEmptyView.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/03/17.
//

import Foundation
import SnapKit

class PolarisStarEmptyView: UIView {
    
    let emptyStarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "imgMainNoJourney1")
        return imageView
    }()
    
    let emptyStarImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "imgMainNoJourney2")
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUIs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUIs() {
        self.addSubview(self.emptyStarImageView)
        self.addSubview(self.emptyStarImageView2)
        self.backgroundColor = .clear
        
        self.emptyStarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(22)
            make.width.equalTo(64)
            make.height.equalTo(61)
        }
        
        self.emptyStarImageView2.snp.makeConstraints { make in
            make.leading.equalTo(emptyStarImageView.snp.trailing)
            make.bottom.equalTo(emptyStarImageView.snp.top)
            make.width.height.equalTo(30)
        }
    }
}
