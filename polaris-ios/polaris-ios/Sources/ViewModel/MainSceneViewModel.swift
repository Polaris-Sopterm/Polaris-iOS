//
//  MainSceneViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import Foundation
import RxSwift
import RxCocoa

enum MainSceneLoadingInfo {
    case finished
    case loading
    case retryNeeded
}

class MainSceneViewModel {
    
    var heightRatio = CGFloat(DeviceInfo.screenHeight/812.0)
    var heightList: [CGFloat] = [CGFloat(52.0),CGFloat(93.0),CGFloat(52.0),CGFloat(87.0),CGFloat(28.0),CGFloat(71),CGFloat(34),CGFloat(86),CGFloat(58)]
    var retryCount: Int = 0
    
    var reloadQueue = DispatchQueue(label: "MainSceneReloadQueue")
    
    var currentDate: PolarisDate {
        MainSceneDateSelector.shared.selectedDate
    }
    
    private let disposeBag = DisposeBag()
    private let deviceRatio = DeviceInfo.screenHeight/812.0
    
    struct Output{
        let starList: BehaviorRelay<[MainStarCVCViewModel]>
        let todoStarList: BehaviorRelay<[MainTodoCVCViewModel]>
        let state: BehaviorRelay<[StarCollectionViewState]>
        let lookBackState: BehaviorRelay<[MainLookBackCellState]>
        let mainTextRelay: BehaviorRelay<[String]>
        let homeModelRelay: BehaviorRelay<[HomeModel]>
        let starLoadingRelay: BehaviorRelay<MainSceneLoadingInfo>
        let todoLoadingRelay: BehaviorRelay<MainSceneLoadingInfo>
    }
    
    func connect() -> Output{
        let starList: BehaviorRelay<[MainStarCVCViewModel]> = BehaviorRelay(value: [])
        let state: BehaviorRelay<[StarCollectionViewState]> = BehaviorRelay(value: [])
        let lookBackState: BehaviorRelay<[MainLookBackCellState]> = BehaviorRelay(value: [])
        let mainTextRelay: BehaviorRelay<[String]> = BehaviorRelay(value: [])
        let homeModelRelay: BehaviorRelay<[HomeModel]> = BehaviorRelay(value: [])
        var mainStarModels: [MainStarModel] = []
        let mainStarModelRelay: BehaviorRelay<[MainStarModel]> = BehaviorRelay(value: [])
        let starLoadingRelay: BehaviorRelay<MainSceneLoadingInfo> = BehaviorRelay(value: .finished)
        let todoLoadingRelay: BehaviorRelay<MainSceneLoadingInfo> = BehaviorRelay(value: .finished)
        
        let todoStarList: BehaviorRelay<[MainTodoCVCViewModel]> = BehaviorRelay(value: [])
        MainSceneDateSelector.shared.selectedDateObservable.subscribe(onNext: { date in
            requestHomeBanner(date: date)
            requestTodos(date: date)
        }).disposed(by: self.disposeBag)
        
        self.reloadRelay.subscribe(onNext: { [weak self] value in
            guard let date = self?.currentDate,
                  value == true
            else { return }
            requestHomeBanner(date: date)
            requestTodos(date: date)
        }).disposed(by: self.disposeBag)
        
        lookBackState.accept([.build])
        starList.accept(self.convertStarCVCViewModel(mainStarModels: mainStarModels))
        
        func requestHomeBanner(date: PolarisDate) {
            starLoadingRelay.accept(.loading)
            let homeAPI = HomeAPI.getHomeBanner(weekModel: date)
            NetworkManager.request(apiType: homeAPI)
                .subscribe(onSuccess: { [weak self] (homeModel: HomeModel) in
                    homeModelRelay.accept([homeModel])
                    self?.lastWeekRelay.accept(homeModel.lastWeek)
                    starLoadingRelay.accept(.finished)
                    for star in homeModel.starList {
                        mainStarModels.append(MainStarModel(starName: star.name, starLevel: star.level))
                    }
                    switch homeModel.homeModelCase {
                    case "journey_complete":
                        if mainStarModels.count == 1 &&
                            mainStarModels[0].starName == "empty" {
                            state.accept([StarCollectionViewState.showEmptyStar])
                            starList.accept([])
                            break
                        }
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
                    
                },onFailure: { _ in
                    starLoadingRelay.accept(.retryNeeded)
                })
                .disposed(by: self.disposeBag)
        }
        
        func requestTodos(date: PolarisDate) {
            todoLoadingRelay.accept(.loading)
            let journeyAPI = JourneyAPI.getWeekJourney(year: date.year, month: date.month, weekNo: date.weekNo)
            var weekJourneyModels: [WeekJourneyModel] = []
            NetworkManager.request(apiType: journeyAPI)
                .subscribe(onSuccess: { [weak self] (journeyModel: JourneyWeekListModel) in
                    weekJourneyModels = journeyModel.journeys!
                    todoLoadingRelay.accept(.finished)
                    todoStarList.accept(self?.convertTodoCVCViewModel(weekJourneyModels: weekJourneyModels, dateInfo: date) ?? [])
                },onFailure: { _ in
                    todoLoadingRelay.accept(.retryNeeded)
                })
                .disposed(by: self.disposeBag)
        }
        
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
    
    func convertWeekJourneyUnderThreeTodos(weekJourneyModel: WeekJourneyModel) -> WeekJourneyModel {
        guard let todos = weekJourneyModel.toDos,
           todos.count > 2
        else {
            return weekJourneyModel
        }
        let cutTodos = Array(todos[0...2])
        let newWeekJourney = WeekJourneyModel(idx: weekJourneyModel.idx, title: weekJourneyModel.title, year: weekJourneyModel.year, month: weekJourneyModel.month, weekNo: weekJourneyModel.weekNo, userIdx: weekJourneyModel.userIdx, value1: weekJourneyModel.value1, value2: weekJourneyModel.value2, toDos: cutTodos)
        return newWeekJourney
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
                thisWeekJouneyModels.append(convertWeekJourneyUnderThreeTodos(weekJourneyModel: weekJourneyModel))
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
    
    func skipRetrospect() {
        guard let lastWeek = lastWeekRelay.value,
                let year = lastWeek.year,
                let month = lastWeek.month,
                let weekNo = lastWeek.weekNo
        else { return }
        let skipDate = PolarisDate(year: year, month: month, weekNo: weekNo)
        let skipAPI = RetrospectAPI.skipRetrospect(date: skipDate)
        NetworkManager.request(apiType: skipAPI)
            .subscribe(onSuccess: { [weak self] (skipModel: RetrospectSkipModel) in
                self?.reloadHome()
            }, onFailure: { error  in
                PolarisToastManager.shared.showToast(with: "여정 돌아보기 건너뛰기가 불가능합니다.")
            })
            .disposed(by: self.disposeBag)
    }
    
    func reloadHome() {
        self.reloadRelay.accept(true)
    }
    
    func reloadInfo() {
        let currentDate = self.currentDate
        MainSceneDateSelector.shared.updateDate(currentDate)
    }
    
    func retryAPIs() {
        DispatchQueue.mainSceneReloadQueue.async { [weak self] in
            guard let self = self else { return }
            switch self.retryCount {
            case 2:
                Thread.sleep(forTimeInterval: 2)
                fallthrough
            case 1:
                Thread.sleep(forTimeInterval: 1)
                fallthrough
            case 0:
                Thread.sleep(forTimeInterval: 1)
                self.retryCount += 1
                self.reloadHome()
            default:
                return
            }
        }
    }
    
    func updateDateInfo(_ dateInfo: PolarisDate) {
        MainSceneDateSelector.shared.updateDate(dateInfo)
    }
    
    func updateDoneStatus(_ todoModel: TodoModel) {
        guard let todoIdx = todoModel.idx else { return }
        
        let edittedIsDone = todoModel.isDone == nil ? true : false
        let todoEditAPI   = TodoAPI.editTodo(idx: todoIdx, isDone: edittedIsDone)
        
        NetworkManager.request(apiType: todoEditAPI).subscribe(onSuccess: { [weak self] (responseModel: TodoModel) in
            guard let currentDate = self?.currentDate else { return }
            
            MainSceneDateSelector.shared.updateDate(currentDate)
            NotificationCenter.default.postUpdateTodo(fromScene: .main)
        }).disposed(by: self.disposeBag)
    }
    
    func changeToImgName(starName: String, level: Int)-> String {
        return String.makeStarImageName(starName: starName, level: level)
    }
    
    var lastWeekRelay = BehaviorRelay<LastWeek?>(value: nil)
    var reloadRelay = BehaviorRelay<Bool>(value: false)
}
