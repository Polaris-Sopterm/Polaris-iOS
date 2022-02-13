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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationProperty()
        self.setupButtons()
        self.registerCell()
        self.setupTableView()
        self.observeViewModel()
        
        self.viewModel.occurViewAction(action: .viewDidLoad)
    }
    
    private func registerCell() {
        RetrospectReportCategory.allCases.forEach {
            self.tableView.registerCell(cell: $0.cellType)
        }
    }
    
    private func setupNavigationProperty() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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
        self.viewModel.reportDateObservable
            .withUnretained(self)
            .observeOnMain(onNext: { owner, currentDate in
                let currentDate = currentDate
                
                let yearText = "\(currentDate.year)년 "
                let monthText = "\(currentDate.month)월 "
                guard let weekNoText = Date.convertWeekNoToString(weekNo: currentDate.weekNo) else { return }
                
                self.dateLabel.text = yearText + monthText + weekNoText
            })
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(self.viewModel.reportObservable, self.viewModel.foundStarObservable)
            .withUnretained(self)
            .observeOnMain(onNext: { owner, tuple in
                let retrospectModel = tuple.0
                let foundStarModel = tuple.1
                                
                owner.tableView.reloadData()
                owner.updateEmptyViewUI(asFoundStar: foundStarModel, asRetrospect: retrospectModel)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.loadingObservable
            .withUnretained(self)
            .observeOnMain(onNext: { owner, loading in
                loading ? owner.startIndicatorAnimation() : owner.stopIndicatorAnimation()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func presentDatePickerView() {
        let viewController = WeekPickerVC.instantiateFromStoryboard(StoryboardName.weekPicker)
        
        guard let pickerVC = viewController              else { return }
        guard let reportDate = self.viewModel.reportDate else { return }
        
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
    
    private func updateEmptyViewUI(asFoundStar foundStar: RetrospectValueListModel, asRetrospect retrospect: RetrospectModel?) {
        if foundStar.isAchieveJourneyAtLeastOne == false {
            self.todoEmptyView.showCrossDissolve()
            self.retrospectEmptyView.hideCrossDissolve()
        } else if foundStar.isAchieveJourneyAtLeastOne == true && retrospect == nil {
            self.todoEmptyView.hideCrossDissolve()
            self.retrospectEmptyView.showCrossDissolve()
        } else if foundStar.isAchieveJourneyAtLeastOne == true && retrospect != nil {
            self.todoEmptyView.hideCrossDissolve()
            self.retrospectEmptyView.hideCrossDissolve()
        } else {
            self.todoEmptyView.showCrossDissolve()
            self.retrospectEmptyView.hideCrossDissolve()
        }
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel = RetrospectReportViewModel()
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var calendarButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var todoEmptyView: UIView!
    @IBOutlet private weak var retrospectEmptyView: UIView!
    
    @IBOutlet private weak var indicatorContainerView: UIView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
}

extension RetrospectReportVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryIndex = indexPath.row
        let reportCategory = RetrospectReportCategory(rawValue: categoryIndex) ?? .foundStar
        let cell = tableView.dequeueReusableCell(cell: reportCategory.cellType, forIndexPath: indexPath)
        
        guard let itemCell = cell else { return UITableViewCell() }
        guard let presentable = self.viewModel.presentable(cellForCategoryAt: reportCategory) else { return UITableViewCell() }
        
        itemCell.configure(presentable: presentable)
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
    
    func weekPickerViewController(_ viewController: WeekPickerVC, didSelectedDate date: PolarisDate) {
        self.viewModel.occurViewAction(action: .weekPickerSelected(date: date))
    }
    
}
