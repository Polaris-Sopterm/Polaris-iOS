//
//  AddTodoViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import Foundation
import RxSwift

class AddTodoViewModel {
    
    var currentDate: Date? {
        if self.currentAddOption == .perDayAddTodo {
            return self.addTodoDate
        } else if self.currentAddOption == .edittedTodo {
            return self.todoDayModel?.date?.convertToDate()?.normalizedDate
        } else {
            return nil
        }
    }
    
    var addOptionCount: Int {
        return (try? self.addListTypes.value().count) ?? 0
    }
    
    let addListTypes      = BehaviorSubject<[AddTodoTableViewCellProtocol.Type]>(value: [])
    
    let addTextSubject    = BehaviorSubject<String?>(value: nil)
    let dropdownSubject   = BehaviorSubject<JourneyTitleModel?>(value: nil)
    let fixOnTopSubject   = BehaviorSubject<Bool?>(value: nil)
    let selectDateSubject = BehaviorSubject<Date?>(value: nil)
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
    
    func setEditTodoModel(_ todo: TodoDayPerModel) {
        self.todoDayModel = todo
    }
    
    func requestAddTodo() {
        self.loadingSubject.onNext(true)
        if self.currentAddOption == .perDayAddTodo {
            self.requestAddTodoDay()
        } else if self.currentAddOption == .perJourneyAddTodo {
            self.requestAddJourney()
        } else if self.currentAddOption == .edittedTodo {
            self.requestEditTodo()
        }
    }
    
    private func requestAddTodoDay() {
        guard let addText = try? self.addTextSubject.value()    else { return }
        guard let fixOnTop = try? self.fixOnTopSubject.value()  else { return }
        guard let addTodoDate = self.currentDate                else { return }
        guard let journey = try? self.dropdownSubject.value()   else { return }
        
        let createTodoAPI = TodoAPI.createToDo(title: addText, date: addTodoDate.convertToString(),
                                               journeyTitle: journey.title ?? "default", journeyIdx: journey.idx, isTop: fixOnTop)
        NetworkManager.request(apiType: createTodoAPI).subscribe(onSuccess: { [weak self] (responseModel: AddTodoResponseModel) in
            self?.completeAddTodoSubject.onNext(())
            self?.loadingSubject.onNext(false)
        }, onFailure: { [weak self] error in
            self?.loadingSubject.onNext(false)
        }).disposed(by: self.disposeBag)
    }
    
    private func requestAddJourney() {
        
    }
    
    private func requestEditTodo() {
        guard let todoModel = self.todoDayModel else { return }
        guard let idx = todoModel.idx           else { return }
        
        guard let edittedText = try? self.addTextSubject.value()      else { return }
        guard let edittedDate = try? self.selectDateSubject.value()   else { return }
        guard let edittedJourney = try? self.dropdownSubject.value()  else { return }
        guard let edittedFixOnTop = try? self.fixOnTopSubject.value() else { return }
        
        let todoEditAPI = TodoAPI.editTodo(idx: idx, title: edittedText, date: edittedDate.convertToString(),
                                           journeyIdx: edittedJourney.idx, isTop: edittedFixOnTop)
        
        NetworkManager.request(apiType: todoEditAPI).subscribe(onSuccess: { [weak self] (responseModel: TodoDayPerModel)  in
            self?.completeAddTodoSubject.onNext(())
            self?.loadingSubject.onNext(false)
        }, onFailure: { [weak self] _ in
            self?.loadingSubject.onNext(false)
        }).disposed(by: self.disposeBag)
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
            Observable.combineLatest(self.addTextSubject, self.selectDateSubject, self.fixOnTopSubject)
                .subscribe(onNext: { [weak self] addText, selectDate, fixOnTop in
                    guard let self = self else { return }
                    guard let addText = addText, !addText.isEmpty,
                          selectDate  != nil,
                          fixOnTop    != nil else {
                        self.addEnableFlagSubject.onNext(false)
                        return
                    }
                    
                    self.addEnableFlagSubject.onNext(true)
                })
                .disposed(by: self.disposeBag)
        } else if addOptions == .addJourney {
            Observable.combineLatest(self.addTextSubject, self.selectStarSubject)
                .subscribe(onNext: { [weak self] addText, selectStar in
                    guard let self = self else { return }
                    guard let addText    = addText, !addText.isEmpty,
                          let selectStar = selectStar, selectStar.count <= 2 && !selectStar.isEmpty else {
                        self.addEnableFlagSubject.onNext(false)
                        return
                    }
                    
                    self.addEnableFlagSubject.onNext(true)
                })
                .disposed(by: self.disposeBag)
        } else if addOptions == .edittedTodo {
            Observable.combineLatest(self.addTextSubject, self.dropdownSubject, self.selectDateSubject, self.fixOnTopSubject)
                .subscribe(onNext: { [weak self] addText, dropdownMenu, selectDate, fixOnTop in
                    guard let self = self else { return }
                    guard addText?.isEmpty == false, selectDate != nil,
                          fixOnTop != nil, dropdownMenu != nil else {
                        self.addEnableFlagSubject.onNext(false)
                        return
                    }
                    
                    self.addEnableFlagSubject.onNext(true)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    // 날짜에 더할때만 씀 - Day Todo
    private(set) var addTodoDate: Date?
    
    // 일정 수정할 때 씀 - Edit Todo
    private(set) var todoDayModel: TodoDayPerModel?
    
    private(set) var currentAddOption: AddTodoVC.AddOptions?
    
}
