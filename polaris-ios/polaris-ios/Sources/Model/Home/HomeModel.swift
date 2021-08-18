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
    let bannerTitle, bannerText, buttonText: String?

    enum CodingKeys: String, CodingKey {
        case homeModelCase = "case"
        case starList, mainText, bannerTitle, bannerText, buttonText
    }
}

// MARK: - StarList
struct StarList: Codable {
    let name: String
    let level: Int
}
