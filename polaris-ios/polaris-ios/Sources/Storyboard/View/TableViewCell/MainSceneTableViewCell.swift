//
//  MainSceneTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/17.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit


enum StarCollectionViewState: Int, CaseIterable {
    case showStar = 1
    case showEmptyStar
    case showLookBack
    case showIncomplete
}


final class MainSceneTableViewCell: MainTableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var starCVCHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var starCV: UICollectionView!
    @IBOutlet private weak var weekContainView: UIView!
    @IBOutlet private weak var weekLabel: UILabel!
    @IBOutlet private weak var nowLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var todoCV: UICollectionView!
    @IBOutlet weak var starLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var todoLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var topButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var heightConstarints: [NSLayoutConstraint]!
    @IBOutlet var yDiffConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var weekContainViewWidth: NSLayoutConstraint!
    
    private let starEmptyView = PolarisStarEmptyView()
    
    private var currentIndex: CGFloat = 0
    private var viewState = StarCollectionViewState.showStar
    private var lookBackState = MainLookBackCellState.lookback
    private let viewModel = MainSceneViewModel()
    private var starTVCViewModel: MainStarTVCViewModel?
    private var dataDriver: Driver<[MainStarCVCViewModel]>?
    private var homeModel: HomeModel?
    private var starList: [MainStarCVCViewModel] = []
    private let disposeBag = DisposeBag()
    private let deviceRatio = DeviceInfo.screenHeight/812.0
    private let deviceRatioSquare = DeviceInfo.screenHeight/812.0*DeviceInfo.screenHeight/812.0
    private let starTVCHeight = 212*(DeviceInfo.screenHeight/812.0)
    
    override static var cellHeight: CGFloat { return DeviceInfo.screenHeight }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addObservers()
        self.setUIs()
        self.setStarCollectionView()
        self.setTodoCollectionView()
        self.bindViewModel()
        self.setupDimView()
    }
    
    func updateDimView(alpha: CGFloat) {
        self.dimView.alpha = alpha
        if alpha == 0 { self.dimView.isHidden = true }
        else          { self.dimView.isHidden = false }
    }
    
    private func addObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.didUpdateTodo(_:)), name: .didUpdateTodo, object: nil)
    }
    
    private func setupDimView() {
        self.dimView.frame           = CGRect(x: 0, y: 0,
                                              width: DeviceInfo.screenWidth, height: type(of: self).cellHeight)
        self.dimView.backgroundColor = .black
        self.dimView.alpha           = 0.0
        self.contentView.addSubview(self.dimView)
    }
    
    private func setUIs(){
        self.contentView.addCometAnimation()
        self.weekContainView.backgroundColor = .white20
        self.weekContainView.setBorder(borderColor: .white60, borderWidth: 1.0)
        self.weekContainView.makeRounded(cornerRadius: 9)
        self.weekLabel.font = UIFont.systemFont(ofSize: 13,weight: .bold)
        self.weekLabel.addCharacterSpacing(kernValue: -0.39)
        self.weekLabel.textColor = .white
        self.nowLabel.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        self.nowLabel.textColor = .white
        
        self.titleLabel.textColor = .white
        if #available(iOS 14.0, *) {
            self.pageControl.backgroundStyle = .minimal
            self.pageControl.allowsContinuousInteraction = false
        }
        self.pageControl.isUserInteractionEnabled = false
        self.topButtonTopConstraint.constant = 48*(DeviceInfo.screenHeight/812.0)
        for ydiffConstraint in self.yDiffConstraints {
            ydiffConstraint.constant *= self.deviceRatioSquare
        }
        
        self.starCVCHeightConstraint.constant *= self.deviceRatio
        for constraint in self.heightConstarints {
            constraint.constant *= self.deviceRatio
        }
        
    }

    private func setStarCollectionView() {
        self.starCV.delegate = self
        self.starCV.registerCell(cell: MainStarCVC.self)
        self.starCV.registerCell(cell: MainLookBackCollectionViewCell.self)
        self.starCV.backgroundColor = .clear
    }
    
    private func setTodoCollectionView() {
        self.todoCV.registerCell(cell: MainTodoCVC.self)
        self.todoCV.backgroundColor = .clear
        self.todoCV.decelerationRate = .fast
        self.todoCV.allowsSelection = false
        self.todoCV.delegate = self
        let layout = self.todoCV.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: DeviceInfo.screenWidth, height: DeviceInfo.screenHeight-285*(DeviceInfo.screenHeight/812.0))
    }
    
    private func setTitle(stars: Int,lookBackState: MainLookBackCellState) {
        self.titleLabel.setPartialBold(originalText: "어제는\n\(stars)개의 별을 발견했어요.", boldText: "\(stars)개의 별", fontSize: 23*deviceRatio, boldFontSize: 23*deviceRatio)
    }
    
    private func setTitleLabel(text: String, boldText: String) {
        self.titleLabel.setPartialBold(originalText: text, boldText: boldText, fontSize: 23*deviceRatio, boldFontSize: 23*deviceRatio)
    }
    
    private func showStarEmptyView() {
        self.addSubview(self.starEmptyView)
        self.starEmptyView.snp.makeConstraints { make in
            make.edges.equalTo(self.starCV)
        }
    }
    
    private func hideStarEmptyView() {
        self.starEmptyView.removeFromSuperview()
    }
    
    private func bindViewModel(){
        let output = viewModel.connect()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.retryInfo), name: .shouldReloadMainScene, object: nil)
        
        output.homeModelRelay.subscribe(onNext: { [weak self] homeModel in
            self?.homeModel = homeModel.last
        })
        .disposed(by: disposeBag)
        
        output.starList.subscribe(onNext: { [weak self] item in
            self?.starList = item
        })
        .disposed(by: disposeBag)
        
        output.state.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            if value.count > 0 {
                self.viewState = value[0]
                if value[0] == .showEmptyStar {
                    self.showStarEmptyView()
                }
                else {
                    self.hideStarEmptyView()
                }
            }
        })
        .disposed(by: disposeBag)
        
        output.lookBackState.subscribe(onNext: { [weak self] value in
            if value.count > 0 {
                self?.lookBackState = value[0]
            }
        })
        .disposed(by: disposeBag)
        
        output.mainTextRelay.subscribe(onNext: { [weak self] texts in
            guard let self = self else { return }
            if texts.count > 1 {
                self.titleLabel.setPartialBold(originalText: texts[0], boldText: texts[1], fontSize: 23*self.deviceRatio, boldFontSize: 23*self.deviceRatio)
            }
        })
        .disposed(by: self.disposeBag)
        
        output.starLoadingRelay.subscribe(onNext: { [weak self] loading in
            switch loading {
            case .loading:
                self?.starLoadingIndicator.startAnimating()
            case .finished:
                self?.starLoadingIndicator.stopAnimating()
            case .retryNeeded:
                NotificationCenter.default.postReloadHome()
            }
        })
        .disposed(by: self.disposeBag)
        
        output.todoLoadingRelay.subscribe(onNext: { [weak self] loading in
            switch loading {
            case .loading:
                self?.todoLoadingIndicator.startAnimating()
            case .finished:
                self?.todoLoadingIndicator.stopAnimating()
            case .retryNeeded:
                NotificationCenter.default.postReloadHome()
            }
        })
        .disposed(by: self.disposeBag)
        
        output.starList.bind(to: self.starCV.rx.items) { [weak self] collectionView, index, item in
            if output.starList.value.last?.starModel.starName != "lookback" {
                let indexPath  = IndexPath(item: index, section: 0)
                let cell = collectionView.dequeueReusableCell(cell: MainStarCVC.self, forIndexPath: indexPath)
                guard let mainStarCell = cell else { return UICollectionViewCell() }
                mainStarCell.cvcViewModel = item
                return mainStarCell
            }
            else {
                guard let self = self else { return UICollectionViewCell() }
                
                let indexPath = IndexPath(item: index, section: 0)
                let cell      = collectionView.dequeueReusableCell(cell: MainLookBackCollectionViewCell.self,
                                                                   forIndexPath: indexPath)
                
                guard let lookbackCell = cell else { return UICollectionViewCell() }
                lookbackCell.delegate = self
                if self.homeModel != nil {
                    lookbackCell.setState(state: self.lookBackState, bannerTitle: self.homeModel!.bannerTitle, bannerText: self.homeModel!.bannerText, buttonText: self.homeModel!.buttonText)
                }
                return lookbackCell
            }
        }.disposed(by: self.disposeBag)
        
        output.todoStarList.bind(to: self.todoCV.rx.items) { [weak self] collectionView, index, item in
            guard let self = self else { return UICollectionViewCell() }
            
            let indexPath = IndexPath(item: index, section: 0)
            let cell      = collectionView.dequeueReusableCell(cell: MainTodoCVC.self, forIndexPath: indexPath)
            
            guard let mainTodoCell = cell else { return UICollectionViewCell() }
            mainTodoCell.viewModel = item
            mainTodoCell.delegate  = self
            self.pageControl.numberOfPages = output.todoStarList.value.count
            return mainTodoCell
        }.disposed(by: self.disposeBag)
        
        MainSceneDateSelector.shared.selectedDateObservable
            .withUnretained(self)
            .subscribe(onNext: { owner, dateInfo in
                guard let weekText = Date.convertWeekNoToString(weekNo: dateInfo.weekNo) else { return }
                
                owner.weekLabel.text =  String(dateInfo.year) + "년 " + String(dateInfo.month) + "월 " + weekText
                owner.weekContainViewWidth.constant = owner.weekLabel.intrinsicContentSize.width + 35.0
            })
            .disposed(by: self.disposeBag)
    }
    
    @objc private func showWeekPicker(){
        guard let weekPickerVC = WeekPickerVC.instantiateFromStoryboard(StoryboardName.weekPicker) else { return }
        guard let visibleController = UIViewController.getVisibleController()                      else { return }
        
        let currentDate = self.viewModel.currentDate
        weekPickerVC.weekDelegate = self
        weekPickerVC.setWeekInfo(
            year: currentDate.year,
            month: currentDate.month,
            weekNo: currentDate.weekNo
        )
        weekPickerVC.presentWithAnimation(from: visibleController)
    }
    
    @IBAction func settingButtonAction(_ sender: Any) {
        let viewController = SettingVC.instantiateFromStoryboard(StoryboardName.setting)

        guard let visibleController = UIViewController.getVisibleController() else { return }
        guard let settingController = viewController                          else { return }
        visibleController.navigationController?.pushViewController(settingController, animated: true)
    }
    
    
    @IBAction func scrollButtonAction(_ sender: Any) {
        guard let visibleController = UIViewController.getVisibleController() else { return }
        guard let mainVC = visibleController as? MainVC                       else { return }
        
        mainVC.scrollToRetrospectCell()
    }
    
    @IBAction func weekButtonAction(_ sender: Any) {
        self.showWeekPicker()
    }
    
    @IBAction func addNewJourneyButton(_ sender: Any) {
        self.presentAddJourneyViewController()
    }
    
    
    @IBAction func reloadButtonAction(_ sender: Any) {
        self.reloadInfo()
    }
    
    @objc func reloadInfo() {
        self.viewModel.reloadInfo()
    }
    
    @objc func retryInfo() {
        self.viewModel.retryAPIs()
    }
    
    @objc private func didUpdateTodo(_ notification: Notification) {
        guard let sceneIdentifier = notification.object as? String      else { return }
        guard sceneIdentifier != MainSceneCellType.main.sceneIdentifier else { return }
        self.viewModel.reloadInfo()
    }
    
    private func presentAddJourneyViewController() {
        let param = AddTodoViewMakingParameter(
            mode: .addJourney(self.viewModel.currentDate),
            delegate: self
        )
        
        guard let addTodoVC = AddTodoViewFactory.makeAddTodoViewController(param: param) else { return }
        guard let visibleController = UIViewController.getVisibleController()            else { return }
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
    private var dimView: UIView = UIView(frame: .zero)
    
}

extension MainSceneTableViewCell: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.starCV {
            if self.viewState == StarCollectionViewState.showStar {
                let starViewModel = self.starList
                return CGSize(width: starViewModel[indexPath.item].cellWidth, height: collectionView.frame.height)
            }
            else {
                return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            }
        }
        else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.starCV {
            if self.viewState == StarCollectionViewState.showStar {
                return 15
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.starCV && self.viewState == StarCollectionViewState.showStar {
            switch self.starList.count {
            case 1 :
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
            case 2 :
                return UIEdgeInsets(top: 0, left: 93, bottom: 0, right: 30)
            case 3 :
                return UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 30)
                
            default :
                return UIEdgeInsets(top: 0, left: 38, bottom: 0, right: 30)
            }
        }
        else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}


extension MainSceneTableViewCell: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == self.todoCV else { return }
        
        let layout = self.todoCV.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        
        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
            roundedIndex = ceil(index)
        } else {
            roundedIndex = round(index)
        }
        
        if currentIndex > roundedIndex {
            currentIndex -= 1
            roundedIndex = currentIndex
        } else if currentIndex < roundedIndex {
            currentIndex += 1
            roundedIndex = currentIndex
        }
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        self.pageControl.currentPage = Int(self.currentIndex)
    }
}

extension MainSceneTableViewCell: LookBackCloseDelegate {
    
    func close() {
        guard let confirmPopupView: PolarisPopupView = UIView.fromNib() else { return }

        confirmPopupView.configure(title: "이번주의 여정 돌아보기를 건너뛸까요?", subTitle: "한 번 건너뛴 여정은 다시 돌아볼 수 없어요.", confirmTitle: "건너뛰기", confirmHandler:  { [weak self] in
            self?.viewModel.skipRetrospect()
        })

        confirmPopupView.show(in: self)
    }
    
    func apply(isLookBack: Bool) {
        if isLookBack {
            let viewController = LookBackMainViewController.instantiateFromStoryboard(StoryboardName.lookback)
            guard let visibleController = UIViewController.getVisibleController() else { return }
            guard let lookbackViewController = viewController                     else { return }
            lookbackViewController.viewModel.dateInfo = self.viewModel.lastWeekRelay.value
            visibleController.navigationController?.pushViewController(lookbackViewController, animated: true)
        } else {
            self.presentAddJourneyViewController()
        }
    }
    
}

extension MainSceneTableViewCell: WeekPickerDelegate {
    
    func weekPickerViewController(_ viewController: WeekPickerVC, didSelectedDate date: PolarisDate) {
        guard let weekNoText = Date.convertWeekNoToString(weekNo: date.weekNo) else { return }
        self.weekLabel.text = "\(date.year)년 " + "\(date.month)월 " + weekNoText
        self.viewModel.updateDateInfo(date)
    }
    
}

extension MainSceneTableViewCell: AddTodoViewControllerDelegate {
    
    func addTodoViewController(_ viewController: AddTodoVC, didCompleteAddMode mode: AddTodoVC.AddMode) {
        self.viewModel.reloadInfo()
        NotificationCenter.default.postUpdateTodo(fromScene: .main)
    }
    
}

extension MainSceneTableViewCell: MainTodoCollectionViewCellDelegate {
    
    func mainTodoCollectionViewCell(_ cell: MainTodoCVC, didTapDone todo: TodoModel) {
        self.viewModel.updateDoneStatus(todo)
    }
    
}
