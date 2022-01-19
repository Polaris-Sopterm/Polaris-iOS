//
//  LookBackSlider.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/01/01.
//

import UIKit

class LookBackSlider: UISlider {
    
    var centerValue: CGPoint?
    var viewModel: LookBackViewModel?
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 11.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.setThumbImage(UIImage(named: "sliderStar2"), for: .normal)
        self.backgroundColor = .clear
        self.minimumValue = 0
        self.maximumValue = 4
        self.setMinimumTrackImage(UIImage(named: "sliderFilled4"), for: .normal)
        self.setMaximumTrackImage(UIImage(named: "sliderBackground"), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
