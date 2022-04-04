//
//  DateTests.swift
//  PolarisBetaTests
//
//  Created by Yunjae Kim on 2022/04/02.
//

import XCTest
import Foundation
//@testable import Polaris

fileprivate extension Date {
    
    static func thursdayOfWeekIncludesDate(date: Date) -> Date {
        return datesIncludedInWeek(fromDate: date.normalizedDate ?? date)[3]
    }
    
    static func weekNoOfDate(date: Date) -> Int {
        Calendar.koreaISO8601.component(.weekOfMonth, from: Date.thursdayOfWeekIncludesDate(date: date))
    }
    
    static func monthOfDate(date: Date) -> Int {
        Calendar.koreaISO8601.component(.month, from: Date.thursdayOfWeekIncludesDate(date: date))
    }
    
    static func yearOfDate(date: Date) -> Int {
        Calendar.koreaISO8601.component(.year, from: Date.thursdayOfWeekIncludesDate(date: date))
    }
    
    static func polarisDateOfDate(date: Date) -> PolarisDate {
        PolarisDate(year: yearOfDate(date: date), month: monthOfDate(date: date), weekNo: weekNoOfDate(date: date))
    }
}

class DateTests: XCTestCase {
    
    func testWhenThursDayIsLastDayOfMonthThenFridayReturnsSameWeekInfo() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let thursDay = try XCTUnwrap(dateFormatter.date(from: "2022-03-31"))
        let friday = try XCTUnwrap(dateFormatter.date(from: "2022-04-01"))
        
        XCTAssertEqual(Date.polarisDateOfDate(date: thursDay), Date.polarisDateOfDate(date: friday))
        XCTAssertTrue(Date.polarisDateOfDate(date: thursDay).month == 3)
    }
    
    func testWhenLastDayOfMonthIsMondayThenReturnsNextMonthInfo() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let monday = try XCTUnwrap(dateFormatter.date(from: "2022-02-28"))
        let tuesday = try XCTUnwrap(dateFormatter.date(from: "2022-03-01"))
        
        XCTAssertEqual(Date.polarisDateOfDate(date: monday), Date.polarisDateOfDate(date: tuesday))
        XCTAssertTrue(Date.polarisDateOfDate(date: monday).month == 3)
    }
    
    func testAlldayOfYearDoesNotReturnsZeroWeekNo() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let firstDate = try XCTUnwrap(dateFormatter.date(from: "2022-01-01"))
        
        for distance in 0...365 {
            guard let calculatedDate = Calendar.koreaISO8601.date(byAdding: .day, value: distance, to: firstDate) else { return }
            let polarisDate = Date.polarisDateOfDate(date: calculatedDate)
            XCTAssertNotEqual(polarisDate.weekNo, 0)
        }
    }
}
