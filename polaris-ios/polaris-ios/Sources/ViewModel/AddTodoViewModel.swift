//
//  AddTodoViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import Foundation
import RxSwift

class AddTodoViewModel {
    
    let addListTypes      = BehaviorSubject<[AddTodoTableViewCellProtocol.Type]>(value: [])
    
    let addTextSubject    = BehaviorSubject<String?>(value: nil)
    let dropdownSubject   = BehaviorSubject<JourneyTitleModel?>(value: nil)
    let fixOnTopSubject   = BehaviorSubject<Bool?>(value: nil)
    let selectDaySubject  = BehaviorSubject<(weekday: Date.WeekDay, day: Int)?>(value: nil)
    let selectStarSubject = BehaviorSubject<Set<PolarisStar>?>(value: nil)
    
    let addEnableFlagSubject   = BehaviorSubject<Bool>(value: false)
    let completeAddTodoSubject = PublishSubject<Void>()
    let loadingSubject         = BehaviorSubject<Bool>(value: false)
    
    func setViewModel(by addOptions: AddTodoVC.AddOptions) {
        self.currentAddOption = addOptions
        self.addListTypes.onNext(addOptions.addCellTypes)
        self.bindEnableFlag(by: addOptions)
    }
    
    func setAddTodoDate(_ date: Date) {
        self.addTodoDate = date
    }
    
    func requestAddTodo() {
        self.loadingSubject.onNext(true)
        if self.currentAddOption == .perDayAddTodo {
            self.requestAddTodoDay()
        } else if self.currentAddOption == .perJourneyAddTodo {
            self.requestAddJourney()
        }
    }
    
    private func requestAddTodoDay() {
        guard let addText = try? self.addTextSubject.value()    else { return }
        guard let fixOnTop = try? self.fixOnTopSubject.value()  else { return }
        guard let addTodoDate = self.addTodoDate                else { return }
        guard let journey = try? self.dropdownSubject.value()   else { return }
        
        let createTodoAPI = TodoAPI.createToDo(title: addText, date: addTodoDate.convertToString(),
                                               journeyTitle: journey.title ?? "default", journeyIdx: journey.idx, isTop: fixOnTop)
        NetworkManager.request(apiType: createTodoAPI).subscribe(onSuccess: { (responseModel: AddTodoResponseModel) in
            self.completeAddTodoSubject.onNext(())
            self.loadingSubject.onNext(false)
        }, onFailure: { error in
            self.loadingSubject.onNext(false)
        }).disposed(by: self.disposeBag)
    }
    
    private func requestAddJourney() {
        
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
    
    private let disposeBag = DisposeBag()
    
    // 날짜에 더할때만 씀
    private(set) var addTodoDate: Date?
    private(set) var currentAddOption: AddTodoVC.AddOptions?
    
}
