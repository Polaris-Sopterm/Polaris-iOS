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
    
    init(
        idx: Int?,
        title: String?,
        year: Int?,
        month: Int?,
        weekNo: Int?,
        userIdx: Int?
    ) {
        self.idx = idx
        self.title = title
        self.year = year
        self.month = month
        self.weekNo = weekNo
        self.userIdx = userIdx
    }
}
