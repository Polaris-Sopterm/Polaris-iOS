//
//  MainSceneViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import Foundation
import RxSwift
import RxCocoa

struct MainSceneViewModel {
    
    var heightRatio = CGFloat(DeviceInfo.screenHeight/812.0)
    var mainStarViewModels: [MainStarCVCViewModel] = []
    var heightList: [CGFloat] = [CGFloat(52.0),CGFloat(93.0),CGFloat(52.0),CGFloat(87.0),CGFloat(28.0),CGFloat(71),CGFloat(34),CGFloat(86),CGFloat(58)]
    
    private var disposeBag = DisposeBag()
    
    struct Input{
        
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
        

        if PolarisUserManager.shared.hasToken{
            print(PolarisUserManager.shared.authToken)
        }

        let homeAPI = HomeAPI.getHomeBanner(isSkipped: false)
        let _ = NetworkManager.request(apiType: homeAPI)
            .subscribe(onSuccess: { (homeModel: HomeModel) in
                print(homeModel)
                homeModelRelay.accept([homeModel])
                for star in homeModel.starList {
                    mainStarModels.append(MainStarModel(starName: star.name, starLevel: star.level))
                }
                
                switch homeModel.homeModelCase {
                case "journey_complete":
                    state.accept([StarCollectionViewState.showStar])
                    lookBackState.accept([.build])
                case "journey_incomplete":
                    state.accept([StarCollectionViewState.showIncomplete])
                    lookBackState.accept([.build])
                default:
                    state.accept([StarCollectionViewState.showLookBack])
                    lookBackState.accept([.lookback])
                }
                
                mainTextRelay.accept(homeModel.mainText)
                
            }, onFailure: { error in
                print(error.localizedDescription)
            })
            .disposed(by: self.disposeBag)
        let todoStarList: BehaviorRelay<[MainTodoCVCViewModel]> = BehaviorRelay(value: [])
        
        let journeyAPI = JourneyAPI.getWeekJourney(year: 2021, month: 7, weekNo: 3)
        let _ = NetworkManager.request(apiType: journeyAPI)
            .subscribe(onSuccess: { (journeyModel: JourneyWeekListModel) in
                print(journeyModel)
            }, onFailure: { error in
                print(String(describing: error))
            })
            .disposed(by: disposeBag)
        
        let todoStarModels = [TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 2일 목요일", fixed: false,checked: false)]),
                              TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: false,checked: false)]),
                              TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: false,checked: false)]),
                              TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: false,checked: false)]),
                              TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: false,checked: false)])]
        lookBackState.accept([.build])
        if mainStarModels.count == 0 {
            state.accept([StarCollectionViewState.showLookBack])
        } else {
            state.accept([StarCollectionViewState.showStar])
        }
        
        
        starList.accept(self.convertStarCVCViewModel(mainStarModels: mainStarModels))
        todoStarList.accept(self.convertTodoCVCViewModel(todoStarModels: todoStarModels))
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
    
    func convertTodoCVCViewModel(todoStarModels: [TodoStarModel]) -> [MainTodoCVCViewModel]{
        var resultList: [MainTodoCVCViewModel] = []
        for (idx,model) in todoStarModels.enumerated() {
            let tvcModels: [MainTodoTVCViewModel] = model.todos.map{MainTodoTVCViewModel(id: IndexPath(row: idx, section: 0),todoModel: $0)}
            let todoListRelay:BehaviorRelay<[MainTodoTVCViewModel]> = BehaviorRelay(value: tvcModels)
            let starNameRelay:BehaviorRelay<String> = BehaviorRelay(value: model.star)
            resultList.append(MainTodoCVCViewModel(todoListRelay: todoListRelay,starName: starNameRelay))
        }
        return resultList
    }
    
    func changeToImgName(starName: String,level: Int)-> String {
        return "".makeStarImageName(starName: starName, level: level)
    }
    
    
    
    
}
