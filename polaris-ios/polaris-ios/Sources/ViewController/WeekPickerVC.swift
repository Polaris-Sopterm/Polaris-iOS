//
//  WeekPickerVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/08/16.
//

import UIKit

class WeekPickerVC: HalfModalVC {

    @IBOutlet weak var weekPickerHalfModalView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var weekPicker: UIPickerView!
    
    private var year = Date.currentYear
    private var month = Date.currentMonth
    private var weekNo = Date.currentWeekNoOfMonth
    
    private var yearList: [Int] = [Date.currentYear-2,Date.currentYear-1,Date.currentYear,Date.currentYear+1,Date.currentYear+2]
    private var monthList = [1,2,3,4,5,6,7,8,9,10,11,12]
    private var numberOfWeeks = 5
    
    private let weekDict = [1:"첫째주",2:"둘째주",3:"셋째주",4:"넷째주",5:"다섯째주"]
    internal weak var weekDelegate: WeekPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.halfModalView = weekPickerHalfModalView
        self.weekPicker.delegate = self
        self.weekPicker.dataSource = self
        self.setUIs()
    }
    
    private func setUIs(){
        self.titleLabel.text = "몇 주차를 확인하고 싶으신가요?"
        self.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.titleLabel.textColor = .maintext
        self.lineView.backgroundColor = .inactivePurple
        self.confirmButton.backgroundColor = .mainSky
        self.confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.confirmButton.makeRounded(cornerRadius: 18)
        self.weekPicker.setValue(UIColor.maintext, forKeyPath: "textColor")
        self.weekPicker.subviews.first?.subviews.last?.backgroundColor = UIColor.red
        self.setWeekPicker()
    }
    
    private func setWeekPicker() {
        self.weekPicker.selectRow(2, inComponent: 0, animated: false)
        self.weekPicker.selectRow(self.month-1, inComponent: 1, animated: false)
        self.weekPicker.selectRow(self.weekNo-1, inComponent: 2, animated: false)
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismissWithAnimation()
    }
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        if let weekNoText = weekDict[self.weekNo] {
            self.weekDelegate?.apply(year: self.year,
                                     month: self.month,
                                     weekNo: self.weekNo,
                                     weekText: String(self.year)+"년 "+String(self.month)+"월 "+weekNoText
            )
        }
      
        self.dismissWithAnimation()
    }
    
    public func setWeekInfo(year: Int, month: Int, weekNo: Int) {
        self.year = year
        self.month = month
        self.weekNo = weekNo
    }
}

extension WeekPickerVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 5
        case 1:
            return 12
        default:
            self.numberOfWeeks = Date.numberOfMondaysInMonth(self.month, forYear: self.year) ?? 4
            return self.numberOfWeeks
        }
    }
    
}

extension WeekPickerVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        33
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView.subviews[1].backgroundColor = .mainSky15
        switch component {
        case 0:
            return String(self.yearList[row])+"년"
        case 1:
            return String(self.monthList[row])+"월"
        default:
            return weekDict[row+1]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0:
            self.year = yearList[row]
            self.weekPicker.reloadComponent(0)
        case 1:
            self.month = monthList[row]
            self.weekPicker.reloadComponent(1)
        default:
            self.weekNo = row+1
            self.weekPicker.reloadComponent(2)
        }
    }
    
}

protocol WeekPickerDelegate: AnyObject {
    func apply(year: Int, month: Int, weekNo: Int, weekText: String)
}
