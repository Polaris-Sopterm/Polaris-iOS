//
//  ShootingComet.swift
//  Polaris
//
//  Created by Dongmin on 2021/07/21.
//

import UIKit

enum ShootingComet: Int, CaseIterable {
    case thinStar = 0, fatStar
    
    var starImage: UIImage? {
        switch self {
        case .thinStar:  return UIImage(named: ImageName.imgShootingstar)
        case .fatStar:   return UIImage(named: ImageName.imgShootingstar2)
        }
    }
    
    var size: CGFloat {
        switch self {
        case .thinStar: return 70
        case .fatStar:  return 120
        }
    }
}
