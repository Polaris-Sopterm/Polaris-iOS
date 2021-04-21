//
//  MainStarCVCViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import Foundation
import UIKit

struct MainStarCVCViewModel {
    
    let starModel: MainStarModel
    let starImgName: String
    let cellWidth: CGFloat
    let starHeight: CGFloat
    
    init(starModel: MainStarModel,starImgName: String,cellWidth: CGFloat, starHeight: CGFloat) {
        self.starModel = starModel
        self.starImgName = starImgName
        self.cellWidth = cellWidth
        self.starHeight = starHeight
    }
    
}
