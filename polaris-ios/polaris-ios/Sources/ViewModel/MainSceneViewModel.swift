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
        var starList: BehaviorRelay<[MainStarCVCViewModel]>
        
    }
    func connect(input: Input) -> Output{
        var starList: BehaviorRelay<[MainStarCVCViewModel]> = BehaviorRelay(value: [])

        var mainStarModels = [MainStarModel(starName: "도전", starLevel: 4),
                               MainStarModel(starName: "행복", starLevel: 4),
                               MainStarModel(starName: "절제", starLevel: 4),
                               MainStarModel(starName: "감사", starLevel: 4),
                               MainStarModel(starName: "휴식", starLevel: 4)]
        
        var cvcModels: [MainStarCVCViewModel] = self.convertCVCViewModel(mainStarModels: mainStarModels)
        starList.accept(cvcModels)
        return Output(starList: starList)
    }
    
    func convertCVCViewModel(mainStarModels: [MainStarModel]) -> [MainStarCVCViewModel]{
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
    
    func changeToImgName(starName: String,level: Int)-> String {
        return "".makeStarImageName(starName: starName, level: level)
    }
    
    
    
    
}
