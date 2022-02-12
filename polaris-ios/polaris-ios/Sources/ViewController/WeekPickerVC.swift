//
//  WeekPickerVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/08/16.
//

import RxSwift
import UIKit

class WeekPickerVC: HalfModalVC {

    @IBOutlet weak var weekPickerHalfModalView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var weekPicker: UIPickerView!
        
    weak var weekDelegate: WeekPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.halfModalView = weekPickerHalfModalView
        self.weekPicker.delegate = self
        self.weekPicker.dataSource = self
        self.setUIs()
        self.observeViewModel()
        
        self.viewModel.occurViewAction(action: .viewDidLoad)
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
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismissWithAnimation()
    }
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        guard let selectedDate = self.viewModel.selectedDate                           else { return }
        guard let weekNoText = Date.convertWeekNoToString(weekNo: selectedDate.weekNo) else { return }
    
        self.weekDelegate?.weekPickerViewController(self, didSelectedDate: selectedDate)
        self.dismissWithAnimation()
    }
    
    func setWeekInfo(year: Int, month: Int, weekNo: Int) {
        let date = PolarisDate(year: year, month: month, weekNo: weekNo)
        self.viewModel.occurViewAction(action: .pickerSelected(date: date))
    }
    
    private func observeViewModel() {
        self.viewModel.loadingObservable
            .withUnretained(self)
            .observeOnMain(onNext: { owner, loading in
                owner.indicatorContainerView.isHidden = loading == false
                loading ? owner.indicatorView.startAnimating() : owner.indicatorView.stopAnimating()
            })
            .disposed(by: self.disposeBag)
            
        self.viewModel.reloadObservable
            .withUnretained(self)
            .observeOnMain(onNext: { owner, _ in
                owner.weekPicker.reloadAllComponents()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.reloadObservable
            .take(1)
            .withUnretained(self)
            .observeOnMain(onNext: { owner, _ in
                guard let selectedDate = owner.viewModel.selectedDate else { return }
                
                let yearRow = owner.viewModel.years.firstIndex(of: selectedDate.year) ?? 0
                let monthRow = selectedDate.month - 1
                let weekNoRow = selectedDate.weekNo - 1
                
                owner.weekPicker.selectRow(yearRow, inComponent: PickerComponent.year.rawValue, animated: false)
                owner.weekPicker.selectRow(monthRow, inComponent: PickerComponent.month.rawValue, animated: false)
                owner.weekPicker.selectRow(weekNoRow, inComponent: PickerComponent.weekNo.rawValue, animated: false)
            })
            .disposed(by: self.disposeBag)
    }
    
    private let viewModel = WeekPickerViewModel()
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var indicatorContainerView: UIView!
    
}

extension WeekPickerVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        PickerComponent.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let pickerComponent = PickerComponent(rawValue: component) else { return 0 }
        
        switch pickerComponent {
        case .year:
            return self.viewModel.years.count
        case .month:
            return Calendar.current.monthSymbols.count
        case .weekNo:
            let defaultWeekNo: Int = 4
            guard let currentSelectedDate = self.viewModel.selectedDate else { return defaultWeekNo }
            return self.viewModel.weekNo(ofYear: currentSelectedDate.year, ofMonth: currentSelectedDate.month) ?? defaultWeekNo
        }
    }
    
}

extension WeekPickerVC: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        33
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView.subviews[1].backgroundColor = .mainSky15
        
        guard let pickerComponent = PickerComponent(rawValue: component) else { return nil }
        
        switch pickerComponent {
        case .year:
            return "\(self.viewModel.years[safe: row] ?? Date.currentYear)" + "년"
        case .month:
            return "\(row + 1)" + "월"
        case .weekNo:
            return Date.convertWeekNoToString(weekNo: row + 1)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let pickerComponent = PickerComponent(rawValue: component) else { return }
        
        guard let currentSelectedDate = self.viewModel.selectedDate else { return }
        
        switch pickerComponent {
        case .year:
            let selectedDate = PolarisDate(
                year: self.viewModel.years[safe: row] ?? Date.currentYear,
                month: currentSelectedDate.month,
                weekNo: currentSelectedDate.weekNo
            )
            self.viewModel.occurViewAction(action: .pickerSelected(date: selectedDate))
            self.weekPicker.reloadAllComponents()
            
        case .month:
            let selectedDate = PolarisDate(
                year: currentSelectedDate.year,
                month: row + 1,
                weekNo: currentSelectedDate.weekNo
            )
            self.viewModel.occurViewAction(action: .pickerSelected(date: selectedDate))
            self.weekPicker.reloadAllComponents()
            
        case .weekNo:
            let selectedDate = PolarisDate(
                year: currentSelectedDate.year,
                month: currentSelectedDate.month,
                weekNo: row + 1
            )
            self.viewModel.occurViewAction(action: .pickerSelected(date: selectedDate))
            self.weekPicker.reloadAllComponents()
        }
    }
    
}

protocol WeekPickerDelegate: AnyObject {
    func weekPickerViewController(_ viewController: WeekPickerVC, didSelectedDate date: PolarisDate)
}


extension WeekPickerVC {
    
    enum PickerComponent: Int, CaseIterable {
        case year, month, weekNo
    }
    
}
