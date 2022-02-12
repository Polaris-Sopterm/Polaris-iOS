//
//  MainSceneViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import Foundation
import RxSwift
import RxCocoa

class MainSceneViewModel {
    
    var heightRatio = CGFloat(DeviceInfo.screenHeight/812.0)
    var heightList: [CGFloat] = [CGFloat(52.0),CGFloat(93.0),CGFloat(52.0),CGFloat(87.0),CGFloat(28.0),CGFloat(71),CGFloat(34),CGFloat(86),CGFloat(58)]
    
    private let disposeBag = DisposeBag()
    private let deviceRatio = DeviceInfo.screenHeight/812.0
    struct Input{
        let forceToShowStar: BehaviorRelay<Bool>
        let dateInfo: BehaviorRelay<PolarisDate>
    }
    
    struct Output{
        let starList: BehaviorRelay<[MainStarCVCViewModel]>
        let todoStarList: BehaviorRelay<[MainTodoCVCViewModel]>
        let state: BehaviorRelay<[StarCollectionViewState]>
        let lookBackState: BehaviorRelay<[MainLookBackCellState]>
        let mainTextRelay: BehaviorRelay<[String]>
        let homeModelRelay: BehaviorRelay<[HomeModel]>
        let starLoadingRelay: BehaviorRelay<Bool>
        let todoLoadingRelay: BehaviorRelay<Bool>
    }
    
    func connect(input: Input) -> Output{
        let starList: BehaviorRelay<[MainStarCVCViewModel]> = BehaviorRelay(value: [])
        let state: BehaviorRelay<[StarCollectionViewState]> = BehaviorRelay(value: [])
        let lookBackState: BehaviorRelay<[MainLookBackCellState]> = BehaviorRelay(value: [])
        let mainTextRelay: BehaviorRelay<[String]> = BehaviorRelay(value: [])
        let homeModelRelay: BehaviorRelay<[HomeModel]> = BehaviorRelay(value: [])
        var mainStarModels: [MainStarModel] = []
        let mainStarModelRelay: BehaviorRelay<[MainStarModel]> = BehaviorRelay(value: [])
        let starLoadingRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        let todoLoadingRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
        input.forceToShowStar.subscribe(onNext: { force in
            starLoadingRelay.accept(true)
            var isForced = force
            
            if self.isAlreadyJumped() && force == false {
                isForced = true
            }
            else if !self.isAlreadyJumped() && force == true {
                self.setJumpDate()
            }
            
            let homeAPI = HomeAPI.getHomeBanner(isSkipped: isForced)
            NetworkManager.request(apiType: homeAPI)
                .subscribe(onSuccess: { [weak self] (homeModel: HomeModel) in
                    homeModelRelay.accept([homeModel])
                    starLoadingRelay.accept(false)
                    for star in homeModel.starList {
                        mainStarModels.append(MainStarModel(starName: star.name, starLevel: star.level))
                    }
                    switch homeModel.homeModelCase {
                    case "journey_complete":
                        state.accept([StarCollectionViewState.showStar])
                        lookBackState.accept([.build])
                        starList.accept(self?.convertStarCVCViewModel(mainStarModels: mainStarModels) ?? [])
                    case "journey_incomplete":
                        state.accept([StarCollectionViewState.showIncomplete])
                        lookBackState.accept([.build])
                        starList.accept([MainStarCVCViewModel(starModel: MainStarModel(starName: "lookback", starLevel: 0), starImgName: "123", cellWidth: 123, starHeight: 123)])
                    default:
                        state.accept([StarCollectionViewState.showLookBack])
                        lookBackState.accept([.lookback])
                        starList.accept([MainStarCVCViewModel(starModel: MainStarModel(starName: "lookback", starLevel: 0), starImgName: "123", cellWidth: 123, starHeight: 123)])
                    }
                    mainTextRelay.accept([homeModel.mainText,homeModel.boldText])
                    mainStarModelRelay.accept(mainStarModels)
                    mainStarModels = []
                    
                })
                .disposed(by: self.disposeBag)
        })
            .disposed(by: self.disposeBag)
        
        
        let todoStarList: BehaviorRelay<[MainTodoCVCViewModel]> = BehaviorRelay(value: [])
        input.dateInfo.subscribe(onNext: { date in
            guard date.year > 0 else { return }
            
            todoLoadingRelay.accept(true)
            let journeyAPI = JourneyAPI.getWeekJourney(year: date.year, month: date.month, weekNo: date.weekNo)
            var weekJourneyModels: [WeekJourneyModel] = []
            NetworkManager.request(apiType: journeyAPI)
                .subscribe(onSuccess: { [weak self] (journeyModel: JourneyWeekListModel) in
                    weekJourneyModels = journeyModel.journeys!
                    todoLoadingRelay.accept(false)
                    todoStarList.accept(self?.convertTodoCVCViewModel(weekJourneyModels: weekJourneyModels, dateInfo: date) ?? [])
                })
                .disposed(by: self.disposeBag)
        })
            .disposed(by: self.disposeBag)
        
        let weekAPI = WeekAPI.getWeekNo(date: Date.normalizedCurrent)
        NetworkManager.request(apiType: weekAPI)
            .subscribe(onSuccess: { [weak self] (weekModel: WeekResponseModel) in
                var year = Date.currentYear
                var month = Date.currentMonth
                if Date.todayDay < 7 * (weekModel.weekNo - 1) {
                    if month == 1 {
                        year -= 1
                        month = 12
                    }
                    else {
                        month -= 1
                    }
                }
                input.dateInfo.accept(DateInfo(year: year, month: month, weekNo: weekModel.weekNo))
            })
            .disposed(by: self.disposeBag)
        
        lookBackState.accept([.build])
        starList.accept(self.convertStarCVCViewModel(mainStarModels: mainStarModels))
        
        return Output(starList: starList,todoStarList: todoStarList,state: state,lookBackState: lookBackState,mainTextRelay: mainTextRelay,homeModelRelay: homeModelRelay, starLoadingRelay: starLoadingRelay, todoLoadingRelay: todoLoadingRelay)
    }
    
    func convertStarCVCViewModel(mainStarModels: [MainStarModel]) -> [MainStarCVCViewModel]{
        var resultList: [MainStarCVCViewModel] = []
        
        switch mainStarModels.count {
        case 1:
            let height = CGFloat(70.0)
            
            resultList.append(MainStarCVCViewModel(starModel: mainStarModels[0], starImgName:  changeToImgName(starName: mainStarModels[0].starName, level: mainStarModels[0].starLevel), cellWidth: DeviceInfo.screenWidth, starHeight: height*self.heightRatio))
            
        case 2 :
            let height = CGFloat(70.0)
            for model in mainStarModels {
                resultList.append(MainStarCVCViewModel(starModel: model, starImgName:  changeToImgName(starName: model.starName, level: model.starLevel), cellWidth: 88.0, starHeight: height*self.heightRatio))
                
            }
        case 3 :
            for (idx,model) in mainStarModels.enumerated() {
                resultList.append(MainStarCVCViewModel(starModel: model, starImgName:  changeToImgName(starName: model.starName, level: model.starLevel), cellWidth: 102.0, starHeight: heightList[idx]*self.heightRatio))
            }
            
            
        default:
            for (idx,model) in mainStarModels.enumerated() {
                resultList.append(MainStarCVCViewModel(starModel: model, starImgName:  changeToImgName(starName: model.starName, level: model.starLevel), cellWidth: 60.0, starHeight: heightList[idx]*self.heightRatio))
            }
        }
        return resultList
    }
    
    func convertTodoCVCViewModel(weekJourneyModels: [WeekJourneyModel],dateInfo: PolarisDate) -> [MainTodoCVCViewModel]{
        var resultList: [MainTodoCVCViewModel] = []
        var thisWeekJouneyModels: [WeekJourneyModel] = []
        // 이번주에 해당하는 Model 추출
        for weekJourneyModel in weekJourneyModels {
            guard let year = weekJourneyModel.year     else { continue }
            guard let month = weekJourneyModel.month   else { continue }
            guard let weekNo = weekJourneyModel.weekNo else { continue }
            if year == dateInfo.year && month == dateInfo.month && weekNo == dateInfo.weekNo {
                thisWeekJouneyModels.append(weekJourneyModel)
            }
        }
        
        for thisWeekjourney in thisWeekJouneyModels {
            var tvcModels: [MainTodoTVCViewModel] = []
            var journeyTitle: String
            var journeyValues: [Journey] = []
            
            if thisWeekjourney.toDos != nil {
                for (idx,model) in thisWeekjourney.toDos!.enumerated() {
                    tvcModels.append(MainTodoTVCViewModel(id: IndexPath(row: idx, section: 0), weekTodo: model))
                }
            }
            
            if let firstValue = thisWeekjourney.value1,
               let firstValueJourney = Journey(rawValue: firstValue) {
                journeyValues.append(firstValueJourney)
            }
            
            if let secondValue = thisWeekjourney.value2,
               let secondValueJourney = Journey(rawValue: secondValue) {
                journeyValues.append(secondValueJourney)
            }
            
            journeyTitle = thisWeekjourney.title ?? ""
            
            let todoListRelay:BehaviorRelay<[MainTodoTVCViewModel]> = BehaviorRelay(value: tvcModels)
            resultList.append(MainTodoCVCViewModel(journeyTitle: journeyTitle,
                                                   journeyValues: journeyValues,
                                                   todoListRelay: todoListRelay))
            
        }
        return resultList
    }
    
    func updateStarList(isSkipped: Bool) {
        self.forceToShowStarRelay.accept(isSkipped)
    }
    
    func updateDateInfo(_ dateInfo: PolarisDate) {
        self.dateInfoRelay.accept(dateInfo)
    }
    
    func updateDoneStatus(_ todoModel: TodoModel) {
        guard let todoIdx = todoModel.idx else { return }
        
        let edittedIsDone = todoModel.isDone == nil ? true : false
        let todoEditAPI   = TodoAPI.editTodo(idx: todoIdx, isDone: edittedIsDone)
        
        NetworkManager.request(apiType: todoEditAPI).subscribe(onSuccess: { [weak self] (responseModel: TodoModel) in
            guard let self = self else { return }
            self.updateDateInfo(self.dateInfoRelay.value)
            
            NotificationCenter.default.post(name: .didUpdateTodo, object: MainSceneCellType.main.sceneIdentifier)
        }).disposed(by: self.disposeBag)
    }
    
    func changeToImgName(starName: String, level: Int)-> String {
        return String.makeStarImageName(starName: starName, level: level)
    }
    
    func isAlreadyJumped() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        if let jumpDate = UserDefaults.standard.value(forKey: UserDefaultsKey.jumpDate) as? String,
           jumpDate == dateString
        {
            return true
        }
        return false
    }
    
    func setJumpDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        UserDefaults.standard.setValue(dateString, forKey: UserDefaultsKey.jumpDate)
    }
    
    private(set) var forceToShowStarRelay = BehaviorRelay(value: false)
    private(set) var dateInfoRelay        = BehaviorRelay<PolarisDate>(value: PolarisDate(year: Date.currentYear,
                                                                                    month: Date.currentMonth,
                                                                                    weekNo: Date.currentWeekNoOfMonth))
    
}
