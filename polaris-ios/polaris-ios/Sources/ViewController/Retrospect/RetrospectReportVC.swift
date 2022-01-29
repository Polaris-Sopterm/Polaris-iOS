//
//  RetrospectVC.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/05.
//

import RxCocoa
import RxSwift
import UIKit

class RetrospectReportVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtons()
        self.registerCell()
        self.setupTableView()
        self.observeViewModel()
    }
    
    private func registerCell() {
        RetrospectReportCategory.allCases.forEach { self.tableView.registerCell(cell: $0.cellType) }
    }
    
    private func setupTableView() {
        self.tableView.allowsSelection = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset = UIEdgeInsets(top: 46, left: 0, bottom: DeviceInfo.bottomSafeAreaInset, right: 0)
    }
    
    private func setupButtons() {
        self.backButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: self.disposeBag)
        
        self.calendarButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.presentDatePickerView()
        }).disposed(by: self.disposeBag)
    }
    
    private func observeViewModel() {
        self.viewModel.reportDateRelay
            .withUnretained(self)
            .observeOnMain(onNext: { owner, currentDate in
                let weekNoDic = [1: "첫째주", 2: "둘째주", 3: "셋째주", 4: "넷째주", 5: "다섯째주"]
                
                let yearText = "\(currentDate.year)년 "
                let monthText = "\(currentDate.month)월 "
                guard let weekNoText = weekNoDic[currentDate.weekNo] else { return }
                
                self.dateLabel.text = yearText + monthText + weekNoText
                
                let date = PolarisDate(
                    year: currentDate.year,
                    month: currentDate.month,
                    weekNo: currentDate.weekNo
                )
                owner.viewModel.requestRetrospectReport(ofDate: date)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.loadingSubject
            .withUnretained(self)
            .observeOnMain(onNext: { owner, loading in
                loading ? owner.startIndicatorAnimation() : owner.stopIndicatorAnimation()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func presentDatePickerView() {
        let viewController = WeekPickerVC.instantiateFromStoryboard(StoryboardName.weekPicker)
        
        guard let pickerVC = viewController else { return }
        
        let reportDate = self.viewModel.reportDate
        pickerVC.setWeekInfo(year: reportDate.year, month: reportDate.month, weekNo: reportDate.weekNo)
        pickerVC.weekDelegate = self
        pickerVC.presentWithAnimation(from: self)
    }
    
    private func startIndicatorAnimation() {
        self.indicatorContainerView.isHidden = false
        self.indicatorView.startAnimating()
    }
    
    private func stopIndicatorAnimation() {
        self.indicatorContainerView.isHidden = true
        self.indicatorView.stopAnimating()
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel = RetrospectReportViewModel()
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var calendarButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var indicatorContainerView: UIView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
}

extension RetrospectReportVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        RetrospectReportCategory.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryIndex = indexPath.row
        let reportCategory = RetrospectReportCategory(rawValue: categoryIndex) ?? .foundStar
        let cell = tableView.dequeueReusableCell(cell: reportCategory.cellType, forIndexPath: indexPath)
        
        guard let itemCell = cell else { return UITableViewCell() }
        // TODO: - Presentable 대입 필요
        // itemCell.configure(presentable: )
        return itemCell
    }
    
}

extension RetrospectReportVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let categoryIndex = indexPath.row
        let reportCategory = RetrospectReportCategory(rawValue: categoryIndex) ?? .foundStar
        return reportCategory.cellType.cellHeight
    }
    
}

extension RetrospectReportVC: WeekPickerDelegate {
    
    func apply(year: Int, month: Int, weekNo: Int, weekText: String) {
        let date = PolarisDate(year: year, month: month, weekNo: weekNo)
        self.viewModel.updateReportDate(date: date)
    }
    
}
