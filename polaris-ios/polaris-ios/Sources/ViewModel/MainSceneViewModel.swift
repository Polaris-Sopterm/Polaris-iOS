//
//  MainSceneViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import Foundation
import RxSwift
import RxCocoa

struct DateInfo {
    let year: Int
    let month: Int
    let weekNo: Int
}

class MainSceneViewModel {
    
    var heightRatio = CGFloat(DeviceInfo.screenHeight/812.0)
    var heightList: [CGFloat] = [CGFloat(52.0),CGFloat(93.0),CGFloat(52.0),CGFloat(87.0),CGFloat(28.0),CGFloat(71),CGFloat(34),CGFloat(86),CGFloat(58)]
    
    private var disposeBag = DisposeBag()
    var year = 2021
    var month = 7
    var weekNo = 3
    
    struct Input{
        let forceToShowStar: Bool
        let dateInfo: DateInfo
    }
    
    struct Output{
        let starList: BehaviorRelay<[MainStarCVCViewModel]>
        let todoStarList: BehaviorRelay<[MainTodoCVCViewModel]>
        let state: BehaviorRelay<[StarCollectionViewState]>
        let lookBackState: BehaviorRelay<[MainLookBackCellState]>
        let mainTextRelay: BehaviorRelay<String>
        let homeModelRelay: BehaviorRelay<[HomeModel]>
    }
    func connect(input: Input) -> Output{
        

        let starList: BehaviorRelay<[MainStarCVCViewModel]> = BehaviorRelay(value: [])
        let state: BehaviorRelay<[StarCollectionViewState]> = BehaviorRelay(value: [])
        let lookBackState: BehaviorRelay<[MainLookBackCellState]> = BehaviorRelay(value: [])
        let mainTextRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
        let homeModelRelay: BehaviorRelay<[HomeModel]> = BehaviorRelay(value: [])
        var mainStarModels: [MainStarModel] = []
        var mainStarModelRelay: BehaviorRelay<[MainStarModel]> = BehaviorRelay(value: [])

        if PolarisUserManager.shared.hasToken{
            print(PolarisUserManager.shared.authToken)
        }

        let homeAPI = HomeAPI.getHomeBanner(isSkipped: input.forceToShowStar)
        let bannerNetworking = NetworkManager.request(apiType: homeAPI)
            .subscribe(onSuccess: { [weak self] (homeModel: HomeModel) in
                print(homeModel)
                homeModelRelay.accept([homeModel])
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
                default:
                    state.accept([StarCollectionViewState.showLookBack])
                    lookBackState.accept([.lookback])
                }
                mainTextRelay.accept(homeModel.mainText)
                mainStarModelRelay.accept(mainStarModels)
                
            }, onFailure: { error in
                print(error.localizedDescription)
            })
            .disposed(by: self.disposeBag)
        let todoStarList: BehaviorRelay<[MainTodoCVCViewModel]> = BehaviorRelay(value: [])
        
        let journeyAPI = JourneyAPI.getWeekJourney(year: 2021, month: 7, weekNo: 3)
        var weekJourneyModels: [WeekJourneyModel] = []
        
        
        NetworkManager.request(apiType: journeyAPI)
            .subscribe(onSuccess: { [weak self] (journeyModel: JourneyWeekListModel) in
                print(journeyModel)
                weekJourneyModels = journeyModel.journeys!
                todoStarList.accept(self?.convertTodoCVCViewModel(weekJourneyModels: weekJourneyModels) ?? [])
            }, onFailure: { error in
                print(String(describing: error))
            })
            .disposed(by: disposeBag)
        
        lookBackState.accept([.build])
        if mainStarModels.count == 0 {
            state.accept([StarCollectionViewState.showLookBack])
        } else {
            state.accept([StarCollectionViewState.showStar])
        }
        
        starList.accept(self.convertStarCVCViewModel(mainStarModels: mainStarModels))
        todoStarList.accept(self.convertTodoCVCViewModel(weekJourneyModels: weekJourneyModels))
        return Output(starList: starList,todoStarList: todoStarList,state: state,lookBackState: lookBackState,mainTextRelay: mainTextRelay,homeModelRelay: homeModelRelay)
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
    
    func convertTodoCVCViewModel(weekJourneyModels: [WeekJourneyModel]) -> [MainTodoCVCViewModel]{
        var resultList: [MainTodoCVCViewModel] = []
        var thisWeekJouneyModels: [WeekJourneyModel] = []
        // 이번주에 해당하는 Model 추출
        for weekJourneyModel in weekJourneyModels {
            guard let year = weekJourneyModel.year     else { continue }
            guard let month = weekJourneyModel.month   else { continue }
            guard let weekNo = weekJourneyModel.weekNo else { continue }
            if year == self.year && month == self.month && weekNo == self.weekNo {
                thisWeekJouneyModels.append(weekJourneyModel)
            }
        }

        for thisWeekjourney in thisWeekJouneyModels {
            var tvcModels: [MainTodoTVCViewModel] = []
            var journeyTitles: [String] = []
            var valueNames: [String] = []
            var tvcModelTemp: [MainTodoTVCViewModel] = []
            if thisWeekjourney.toDos != nil {
                for (idx,model) in thisWeekjourney.toDos!.enumerated() {
                    tvcModels.append(MainTodoTVCViewModel(id: IndexPath(row: idx, section: 0), weekTodo: model))
                }
            }
            valueNames.append(thisWeekjourney.value1!)
            valueNames.append(thisWeekjourney.value2!)
            journeyTitles.append(thisWeekjourney.title ?? "")
            let todoListRelay:BehaviorRelay<[MainTodoTVCViewModel]> = BehaviorRelay(value: tvcModels)
            let journeyNameRelay:BehaviorRelay<[String]> = BehaviorRelay(value: journeyTitles)
            let valueNameRelay:BehaviorRelay<[String]> = BehaviorRelay(value: valueNames)
            resultList.append(MainTodoCVCViewModel(todoListRelay: todoListRelay,journeyNameRelay: journeyNameRelay,valueRelay: valueNameRelay))

        }
        return resultList
    }
    
    func changeToImgName(starName: String,level: Int)-> String {
        return "".makeStarImageName(starName: starName, level: level)
    }
    
    
    
    
}
