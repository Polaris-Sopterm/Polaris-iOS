//
//  TodoDateViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/15.
//

import Foundation
import RxSwift
import RxCocoa

class TodoDateViewModel {
    
    
    
    let todoFetchFinished = PublishSubject<Void>()
    
    
    var dates: [String] = []
    var todos: [[TodoModel]] = []
    var disposeBag = DisposeBag()
    var todoDateModels: [TodoDateModel] = []
    
    
    struct Input{
        let checkButtonClicked: Observable<IndexPath>
        
    }
    
    struct Output{
        let dataDriver: Driver<[TodoDateModel]>
    }
   

    func connect(input: Input) -> Output {
        todoDateModels = [TodoDateModel(date: "4월 12일 월요일", todos: [TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "폴라리스", fixed: true,checked: false),TodoModel(todoTitle: "메인화면 완성하기", todoSubtitle: "폴라리스", fixed: false,checked: false)]),TodoDateModel(date: "4월 13일 화요일", todos: [TodoModel(todoTitle: "2_1", todoSubtitle: "0.1", fixed: true,checked: false),TodoModel(todoTitle: "2_2", todoSubtitle: "0.2", fixed: false,checked: false)]),TodoDateModel(date: "4월 14일 수요일", todos: [TodoModel(todoTitle: "3_1", todoSubtitle: "0.1", fixed: true,checked: false),TodoModel(todoTitle: "3_2", todoSubtitle: "0.2", fixed: false,checked: false)]),TodoDateModel(date: "4월 15일 목요일", todos: [TodoModel(todoTitle: "4_1", todoSubtitle: "0.1", fixed: true,checked: false),TodoModel(todoTitle: "4_2", todoSubtitle: "0.2", fixed: false,checked: false)])]
        let dataDriver: Driver<[TodoDateModel]> = Observable.of(todoDateModels).asDriver(onErrorJustReturn: [])
      
        input.checkButtonClicked.flatMapLatest{
            return Observable.of($0)
        }.subscribe(onNext: { indexPath in
             self.todoDateModels[indexPath.section].todos[indexPath.row].checked = !self.todoDateModels[indexPath.section].todos[indexPath.row].checked
             self.todoFetchFinished.onNext(())
        },onDisposed: {
            
        })
    
         .disposed(by: disposeBag)
 
    
        
        return Output(dataDriver: dataDriver)
        
        
    }
    


    
    
}
