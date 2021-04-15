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
    
    
    init() {
        bind()
    }
    
    private func bind() {
        
        dates = ["4월 12일","4월 13일","4월 14일","4월 15일"]
        todos = [[TodoModel(todoTitle: "1_1", todoSubtitle: "0.1", fixed: true,checked: false),TodoModel(todoTitle: "1_2", todoSubtitle: "0.2", fixed: false,checked: false)],[TodoModel(todoTitle: "2_1", todoSubtitle: "0.1", fixed: true,checked: false),TodoModel(todoTitle: "2_2", todoSubtitle: "0.2", fixed: false,checked: false)],[TodoModel(todoTitle: "3_1", todoSubtitle: "0.1", fixed: true,checked: false),TodoModel(todoTitle: "3_2", todoSubtitle: "0.2", fixed: false,checked: false)],[TodoModel(todoTitle: "4_1", todoSubtitle: "0.1", fixed: true,checked: false),TodoModel(todoTitle: "4_2", todoSubtitle: "0.2", fixed: false,checked: false)]]
        todoFetchFinished.onNext(())
        
        
    }
    
    
    
}
