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
    
    struct Input{
    
    }
    
    struct Output{
        let starList: BehaviorRelay<[MainStarCVCViewModel]>
        let todoStarList: BehaviorRelay<[MainTodoCVCViewModel]>
        
    }
    func connect(input: Input) -> Output{
        let starList: BehaviorRelay<[MainStarCVCViewModel]> = BehaviorRelay(value: [])

        let mainStarModels = [MainStarModel(starName: "도전", starLevel: 4),
                               MainStarModel(starName: "행복", starLevel: 4),
                               MainStarModel(starName: "절제", starLevel: 4),
                               MainStarModel(starName: "감사", starLevel: 4),
                               MainStarModel(starName: "휴식", starLevel: 4)]
        
        
        let todoStarList: BehaviorRelay<[MainTodoCVCViewModel]> = BehaviorRelay(value: [])
        let todoStarModels = [TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 2일 목요일", fixed: false,checked: false)]),
                              TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: false,checked: false)]),
                              TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: false,checked: false)]),
                              TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: false,checked: false)]),
                              TodoStarModel(star: "폴라리스", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "3월 1일 수요일", fixed: false,checked: false)])]
        
       
        

        starList.accept(self.convertStarCVCViewModel(mainStarModels: mainStarModels))
        todoStarList.accept(self.convertTodoCVCViewModel(todoStarModels: todoStarModels))
        return Output(starList: starList,todoStarList: todoStarList)
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
