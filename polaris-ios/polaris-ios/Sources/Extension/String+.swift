//
//  String+.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/19.
//

import Foundation

extension String {
   
    func makeStarImageName(starName: String,level: Int) -> String{
        let category = StarNames.starDict[starName] ?? "Happiness"
        return "img"+category+"0"+String(level)
    }
    
}
