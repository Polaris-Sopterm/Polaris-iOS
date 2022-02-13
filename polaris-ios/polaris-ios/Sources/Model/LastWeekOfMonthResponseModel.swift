//
//  LastWeekOfMonthResponseModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/02/09.
//

import Foundation

struct LastWeekOfMonthResponseModel: Codable {
    let data: [LastWeekOfMonthDataModel]
}

struct LastWeekOfMonthDataModel: Codable {
    let year: Int
    let jan: WeekNumberModel
    let feb: WeekNumberModel
    let mar: WeekNumberModel
    let apr: WeekNumberModel
    let may: WeekNumberModel
    let jun: WeekNumberModel
    let jul: WeekNumberModel
    let aug: WeekNumberModel
    let sep: WeekNumberModel
    let oct: WeekNumberModel
    let nov: WeekNumberModel
    let dec: WeekNumberModel
    
    enum CodingKeys: String, CodingKey {
        case year
        case jan = "Jan"
        case feb = "Feb"
        case mar = "Mar"
        case apr = "Apr"
        case may = "May"
        case jun = "Jun"
        case jul = "Jul"
        case aug = "Aug"
        case sep = "Sep"
        case oct = "Oct"
        case nov = "Nov"
        case dec = "Dec"
    }
    
    func weekNo(ofMonth month: Int) -> Int? {
        switch month {
        case 1:  return self.jan.weekNo
        case 2:  return self.feb.weekNo
        case 3:  return self.mar.weekNo
        case 4:  return self.apr.weekNo
        case 5:  return self.may.weekNo
        case 6:  return self.jun.weekNo
        case 7:  return self.jul.weekNo
        case 8:  return self.aug.weekNo
        case 9:  return self.sep.weekNo
        case 10: return self.oct.weekNo
        case 11: return self.nov.weekNo
        case 12: return self.dec.weekNo
        default: return nil
        }
    }
    
}

struct WeekNumberModel: Codable {
    let weekNo: Int
}
