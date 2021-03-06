//
//  HomeModel.swift
//  Polaris
//
//  Created by Yunjae Kim on 2021/07/30.
//

import Foundation

// MARK: - HomeModel
struct HomeModel: Codable {
    let homeModelCase: String
    let starList: [StarList]
    let mainText: String
    let boldText: String
    let bannerTitle, bannerText, buttonText: String?
    let lastWeek: LastWeek

    enum CodingKeys: String, CodingKey {
        case homeModelCase = "case"
        case starList, mainText, boldText, bannerTitle, bannerText, buttonText, lastWeek
    }
}

// MARK: - StarList
struct StarList: Codable {
    let name: String
    let level: Int
}

struct LastWeek: Codable {
    let year, month, weekNo: Int?
}
