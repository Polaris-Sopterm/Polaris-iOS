//
//  String+.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/19.
//

import Foundation

extension String {
    static let starDict: Dictionary<String,String> = ["행복":"Happiness","절제":"Control",
                                                      "감사":"Thanks","휴식":"Rest",
                                                      "건강":"Health","성장":"Growth",
                                                      "변화":"Change","극복":"Overcome",
                                                      "도전":"Challenge"]
    func makeStarImageName(starName: String,level: Int) -> String{
        let category = String.starDict[starName] ?? "Happiness"
        return "img"+category+"0"+String(level)
    }
    
}
