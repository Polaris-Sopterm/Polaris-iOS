//
//  JourneyTitleListModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/08.
//

import Foundation

struct JourneyTitleModel: Codable {
    let idx: Int?
    let title: String?
    let year: Int?
    let month: Int?
    let weekNo: Int?
    let userIdx: Int?
}

extension JourneyTitleModel {
    
    var displayTitle: String? {
        return title == "default" ? "선택 안함" : self.title
    }
    
}
