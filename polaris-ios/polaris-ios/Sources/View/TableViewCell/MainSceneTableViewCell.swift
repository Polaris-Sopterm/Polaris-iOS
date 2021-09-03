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
    
    private var currentIndex: CGFloat = 0
    private var viewState = StarCollectionViewState.showStar
    private var lookBackState = MainLookBackCellState.lookback
    private let viewModel = MainSceneViewModel()
    private var starTVCViewModel: MainStarTVCViewModel?
    private var dataDriver: Driver<[MainStarCVCViewModel]>?
    private var homeModel: HomeModel?
    private var starList: [MainStarCVCViewModel] = []
    private let disposeBag = DisposeBag()
    private let starTVCHeight = 212*(DeviceInfo.screenHeight/812.0)
    private var dateInfo = DateInfo(year: Date.currentYear, month: Date.currentMonth, weekNo: Date.currentWeekNoOfMonth)
    override static var cellHeight: CGFloat { return DeviceInfo.screenHeight }
    private let weekDict = [1:"첫째주",2:"둘째주",3:"셋째주",4:"넷째주",5:"다섯째주"]
    
    private let forceToShowStarRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let dateInfoRelay: BehaviorRelay<DateInfo> = BehaviorRelay(value: DateInfo(year: Date.currentYear, month: Date.currentMonth, weekNo: Date.currentWeekNoOfMonth))

    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    private func setupDimView() {
        self.dimView.frame           = CGRect(x: 0, y: 0,
                                              width: DeviceInfo.screenWidth, height: type(of: self).cellHeight)
        self.dimView.backgroundColor = .black
        self.dimView.alpha           = 0.0
        self.contentView.addSubview(self.dimView)
    }
    
    private var dimView: UIView = UIView(frame: .zero)
    
    private func setUIs(){
        for _ in 0...2{
            self.cometAnimation()
        }
        self.weekContainView.backgroundColor = .white60
        self.weekContainView.setBorder(borderColor: .white, borderWidth: 1.0)
        self.weekContainView.makeRounded(cornerRadius: 9)
        self.weekLabel.font = UIFont.systemFont(ofSize: 13,weight: .bold)
        self.weekLabel.addCharacterSpacing(kernValue: -0.39)
        if let weekText = self.weekDict[Date.currentWeekNoOfMonth] {
            self.weekLabel.text = String(Date.currentYear)+"년 "+String(Date.currentMonth)+"월"+weekText
        }
        self.weekLabel.textColor = .white
        self.nowLabel.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        self.nowLabel.textColor = .white
        
        self.titleLabel.textColor = .white
        if #available(iOS 14.0, *) {
            self.pageControl.backgroundStyle = .minimal
            self.pageControl.allowsContinuousInteraction = false
        }
        self.pageControl.isUserInteractionEnabled = false
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
        self.todoCV.delegate = self
        let layout = self.todoCV.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: DeviceInfo.screenWidth, height: DeviceInfo.screenHeight-285*(DeviceInfo.screenHeight/812.0))
    }
    
    private func setTitle(stars: Int,lookBackState: MainLookBackCellState) {
        self.titleLabel.setPartialBold(originalText: "어제는\n\(stars)개의 별을 발견했어요.", boldText: "\(stars)개의 별", fontSize: 23, boldFontSize: 23)
    }
    
    private func setTitleLabel(text: String, boldText: String) {
        self.titleLabel.setPartialBold(originalText: text, boldText: boldText, fontSize: 23, boldFontSize: 23)
    }
    
    private func bindViewModel(){
        let input = MainSceneViewModel.Input(forceToShowStar: self.forceToShowStarRelay,dateInfo: self.dateInfoRelay)
        let output = viewModel.connect(input: input)
        output.homeModelRelay.subscribe(onNext: { [weak self] homeModel in
            self?.homeModel = homeModel.last
        })
        .disposed(by: disposeBag)
        
        
        output.starList.subscribe(onNext: { [weak self] item in
            self?.starList = item
        })
        .disposed(by: disposeBag)
    
        output.state.subscribe(onNext: { [weak self] value in
            if value.count > 0 {
                self?.viewState = value[0]
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
                self.titleLabel.setPartialBold(originalText: texts[0], boldText: texts[1], fontSize: 23, boldFontSize: 23)
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
            self.pageControl.numberOfPages = output.todoStarList.value.count
            return mainTodoCell
        }.disposed(by: self.disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTodos), name: NSNotification.Name("checkButton"), object: nil)
    }
    
    private func setCometLayout(comet: UIImageView,size: Int) {
        let heightConst = CGFloat(Int.random(in: 0...400))
        var width: CGFloat = 0.0
        if size == 0 {
            width = 70.0
        }
        else {
            width = 120.0
        }
        self.addSubview(comet)
        comet.translatesAutoresizingMaskIntoConstraints = false
        comet.leftAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        comet.bottomAnchor.constraint(equalTo: self.topAnchor,constant: heightConst).isActive = true
        comet.heightAnchor.constraint(equalToConstant: width).isActive = true
        comet.widthAnchor.constraint(equalToConstant: width).isActive = true
        
    }
    
    
    private func cometAnimation(){
        
        let cometImgNames = [ImageName.imgShootingstar,ImageName.imgShootingstar2]
        
        //        0: small, 1 : big
        let cometSize = Int.random(in: 0...1)
        let comet = UIImageView(image: UIImage(named: cometImgNames[cometSize]))
        
        setCometLayout(comet: comet, size: cometSize)
        let duration = Double(Int.random(in: 15...60))/10.0
        
        UIView.animate(withDuration: duration,delay:0.0, options:.curveEaseIn,animations: {
            comet.transform = CGAffineTransform(translationX: -DeviceInfo.screenWidth-120, y: DeviceInfo.screenWidth+120.0)
        }, completion: { finished in
            comet.removeFromSuperview()
            self.cometAnimation()
        })
    }
    
    @objc private func showWeekPicker(){
        guard let weekPickerVC = WeekPickerVC.instantiateFromStoryboard(StoryboardName.weekPicker),
              let visibleController = UIViewController.getVisibleController() else { return }
        weekPickerVC.weekDelegate = self
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
        
        mainVC.scrollToTodoListCell()
    }
    
    @IBAction func weekButtonAction(_ sender: Any) {
        self.showWeekPicker()
    }
    
    @IBAction func addNewJourneyButton(_ sender: Any) {
        let viewController = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo)
        
        guard let visibleController = UIViewController.getVisibleController() else { return }
        guard let addTodoVC = viewController                                  else { return }
        addTodoVC.setAddOptions(.addJourney)
        addTodoVC.delegate = self
        addTodoVC.presentWithAnimation(from: visibleController)
    }
    
    @objc private func reloadTodos(){
        let dateInfo = self.dateInfoRelay.value
        self.dateInfoRelay.accept(DateInfo(year: dateInfo.year, month: dateInfo.month, weekNo: dateInfo.weekNo))
    }
    
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
        self.forceToShowStarRelay.accept(true)
    }
    
    func apply(isLookBack: Bool) {
        if isLookBack {
            #warning("재은 - 여정 돌아보기(회고) 버튼")
        } else {
            #warning("동민 - Journey 추가 버튼")
        }
    }
    
}

extension MainSceneTableViewCell: WeekPickerDelegate {
    
    func apply(year: Int, month: Int, weekNo: Int, weekText: String) {
        self.weekLabel.text = weekText
        self.forceToShowStarRelay.accept(true)
        self.dateInfoRelay.accept(DateInfo(year: year, month: month, weekNo: weekNo))
    }

}

extension MainSceneTableViewCell: AddTodoViewControllerDelegate {
    
    func addTodoViewController(_ viewController: AddTodoVC, didCompleteAddOption option: AddTodoVC.AddOptions) {
        
    }
    
}
