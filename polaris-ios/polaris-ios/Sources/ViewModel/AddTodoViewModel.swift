//
//  AddTodoViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import Foundation
import RxSwift

class AddTodoViewModel {
    
    var addListTypes      = BehaviorSubject<[AddTodoTableViewCellProtocol.Type]>(value: [])
    
    var addTextSubject    = BehaviorSubject<String?>(value: nil)
    var dropdownSubject   = BehaviorSubject<String?>(value: nil)
    var fixOnTopSubject   = BehaviorSubject<Bool?>(value: nil)
    var selectDaySubject  = BehaviorSubject<(weekday: Date.WeekDay, day: Int)?>(value: nil)
    var selectStarSubject = BehaviorSubject<Set<PolarisStar>?>(value: nil)
    
    var addEnableFlagSubject = BehaviorSubject<Bool>(value: false)
    
    func setViewModel(by addOptions: AddTodoVC.AddOptions) {
        self.currentAddOption = addOptions
        self.addListTypes.onNext(addOptions.addCellTypes)
        self.bindEnableFlag(by: addOptions)
    }
    
    func requestAddTodo() {
        guard let currentAddOption = self.currentAddOption else { return }
        
        if currentAddOption == .perDayAddTodo {
            self.requestAddTodoDay()
        } else if currentAddOption == .perJourneyAddTodo {
            self.requestAddTodoJourney()
        }
    }
    
    private func bindEnableFlag(by addOptions: AddTodoVC.AddOptions) {
        if addOptions == .perDayAddTodo {
            Observable.combineLatest(self.addTextSubject, self.dropdownSubject, self.fixOnTopSubject)
                .subscribe(onNext: { [weak self] addText, dropdownMenu, fixOnTop in
                    guard let self = self else { return }
                    guard let addText = addText, !addText.isEmpty, fixOnTop != nil else {
                        self.addEnableFlagSubject.onNext(false)
                        return
                    }
                    
                    self.addEnableFlagSubject.onNext(true)
                })
                .disposed(by: self.disposeBag)
        } else if addOptions == .perJourneyAddTodo {
            Observable.combineLatest(self.addTextSubject, self.selectDaySubject, self.fixOnTopSubject)
                .subscribe(onNext: { [weak self] addText, selectDay, fixOnTop in
                    guard let self = self else { return }
                    guard let addText    = addText, !addText.isEmpty,
                          selectDay      != nil,
                          fixOnTop       != nil else { self.addEnableFlagSubject.onNext(false); return }
                    
                    self.addEnableFlagSubject.onNext(true)
                })
                .disposed(by: self.disposeBag)
        } else {
            Observable.combineLatest(self.addTextSubject, self.selectStarSubject)
                .subscribe(onNext: { [weak self] addText, selectStar in
                    guard let self = self else { return }
                    guard let addText    = addText, !addText.isEmpty,
                          let selectStar = selectStar, selectStar.count <= 2 && !selectStar.isEmpty else { self.addEnableFlagSubject.onNext(false); return }
                    
                    self.addEnableFlagSubject.onNext(true)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    private func requestAddTodoDay() {
        guard let addText = try? self.addTextSubject.value()    else { return }
        guard let fixOnTop = try? self.fixOnTopSubject.value()  else { return }
        
        #warning("여기에 추가해야 함.. request API")
    }
    
    private func requestAddTodoJourney() {
        
    }
    
    private let disposeBag = DisposeBag()
    
    private(set) var currentAddOption: AddTodoVC.AddOptions?
    
}
