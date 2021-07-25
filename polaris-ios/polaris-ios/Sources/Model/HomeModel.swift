//
//  HomeModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/07/21.
//

import Foundation

// MARK: - HomeModel
struct HomeModel: Codable {
    let homeModelCase: String
    let starList: StarList
    let mainText: String
    let bannerTitle, bannerText, buttonText: String?

    enum CodingKeys: String, CodingKey {
        case homeModelCase = "case"
        case starList, mainText, bannerTitle, bannerText, buttonText
    }
}

// MARK: - StarList
struct StarList: Codable {
    let 행복, 절제, 감사, 휴식, 건강, 성장, 변화, 극복, 도전 : Int
}
