//
//  AddTodoViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import Foundation
import RxSwift
import RxRelay

class AddTodoViewModel {
    
    var currentDate: Date? {
        guard let addMode = self.addMode else { return nil }
        switch addMode {
        case .addDayTodo(let date):
            return date
            
        case .editTodo(let todo):
            return todo.date?.convertToDate()?.normalizedDate
            
        default:
            return nil
        }
    }
    
    var addMode: AddTodoVC.AddMode? {
        self.addModeRelay.value
    }
    
    let addListTypes = BehaviorSubject<[AddTodoTableViewCellProtocol.Type]>(value: [])
    
    let addTextRelay = BehaviorRelay<String?>(value: nil)
    let dropdownRelay = BehaviorRelay<JourneyTitleModel?>(value: nil)
    let fixOnTopRelay = BehaviorRelay<Bool?>(value: nil)
    let selectDateRelay = BehaviorRelay<Date?>(value: nil)
    let selectJourneyRelay = BehaviorRelay<Set<Journey>?>(value: nil)
    
    let addEnableFlagSubject = BehaviorSubject<Bool>(value: false)
    let completeRequestSubject = PublishSubject<Void>()
    let loadingSubject = BehaviorSubject<Bool>(value: false)
    
    init() {
        self.observeMode(self.addModeRelay)
        self.observeViewEvent(self.viewEventRelay)
    }
    
    func setAddMode(_ mode: AddTodoVC.AddMode) {
        self.addModeRelay.accept(mode)
    }
    
    func occur(viewEvent: ViewEvent) {
        self.viewEventRelay.accept(viewEvent)
    }
    
    private func observeMode(_ modeRelay: BehaviorRelay<AddTodoVC.AddMode?>) {
        modeRelay
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { owner, mode in
                owner.bindEnableFlag(by: mode.addOptions)
                owner.addListTypes.onNext(mode.addOptions.addCellTypes)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func observeViewEvent(_ viewEventRelay: PublishRelay<ViewEvent>) {
        viewEventRelay
            .withUnretained(self)
            .subscribe(onNext: { owner, viewEvent in
                owner.handleViewEvent(viewEvent)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .didTapAddButton:
            guard let mode = self.addModeRelay.value else { return }
            self.executeAddAction(asMode: mode)
            
        case .didTapDeleteJourney:
            self.executeDeleteAction()
        }
    }
    
    private func executeAddAction(asMode mode: AddTodoVC.AddMode) {
        var successObservable: Observable<Bool>
        switch mode {
        case .addDayTodo(let date):
            successObservable = self.addDayTodoObservable(ofDate: date)
            
        case .addJourneyTodo(let journey):
            successObservable = self.addJourneyTodoObservable(ofJourney: journey)
            
        case .addJourney(let polarisDate):
            successObservable = self.addJourneyObservable(ofPolarisDate: polarisDate)
            
        case .editTodo(let todo):
            successObservable = self.editTodoObservable(ofTodo: todo)
            
        case .editJourney(let journey):
            successObservable = self.editJourneyObservable(ofJourney: journey)
        }
        
        self.loadingSubject.onNext(true)
        successObservable
            .withUnretained(self)
            .do(
                onNext: { owner, _ in owner.loadingSubject.onNext(false) },
                onError: { [weak self] _ in self?.loadingSubject.onNext(false) }
            )
            .subscribe(onNext: { owner, isSuccess in
                guard isSuccess == true else { return }
                owner.completeRequestSubject.onNext(())
            })
            .disposed(by: self.disposeBag)
    }
    
    private func executeDeleteAction() {
        self.deleteJourneyObservable()
            .withUnretained(self)
            .do(
                onNext: { owner, _ in owner.loadingSubject.onNext(false) },
                onError: { [weak self] _ in self?.loadingSubject.onNext(false) }
            )
            .subscribe(onNext: { owner, isSuccess in
                guard isSuccess == true else { return }
                owner.completeRequestSubject.onNext(())
            })
            .disposed(by: self.disposeBag)
    }
    
    private func addDayTodoObservable(ofDate date: Date) -> Observable<Bool> {
        guard let addText = self.addTextRelay.value   else { return .just(false) }
        guard let fixOnTop = self.fixOnTopRelay.value else { return .just(false) }
        
        let journey = self.dropdownRelay.value
        let createTodoAPI = TodoAPI.createToDo(
            title: addText,
            date: date.convertToString(),
            journeyIdx: journey?.idx,
            isTop: fixOnTop
        )
        
        return NetworkManager.request(apiType: createTodoAPI)
            .asObservable()
            .map { (responseModel: AddTodoResponseModel) in
                return true
            }
    }
    
    private func addJourneyTodoObservable(ofJourney journey: WeekJourneyModel) -> Observable<Bool> {
        guard let addText = self.addTextRelay.value        else { return .just(false) }
        guard let addTodoDate = self.selectDateRelay.value else { return .just(false) }
        guard let fixOnTop = self.fixOnTopRelay.value      else { return .just(false) }
        
        let createTodoAPI = TodoAPI.createToDo(
            title: addText,
            date: addTodoDate.convertToString(),
            journeyIdx: journey.idx,
            isTop: fixOnTop
        )
        
        return NetworkManager.request(apiType: createTodoAPI)
            .asObservable()
            .map { (responseModel: AddTodoResponseModel) in
                return true
            }
    }
    
    private func addJourneyObservable(ofPolarisDate date: PolarisDate) -> Observable<Bool> {
        guard let addText = self.addTextRelay.value          else { return .just(false) }
        guard var journeySet = self.selectJourneyRelay.value else { return .just(false) }
        
        let firstJourney: Journey   = journeySet.removeFirst()
        let secondJourney: Journey? = journeySet.isEmpty == false ? journeySet.removeFirst() : nil
        
        let createJourneyAPI = JourneyAPI.createJourney(
            title: addText,
            value1: firstJourney.rawValue,
            value2: secondJourney?.rawValue,
            date: date
        )
        
        return NetworkManager.request(apiType: createJourneyAPI)
            .asObservable()
            .map { (journeyModel: WeekJourneyModel) in
                return true
            }
    }
    
    private func editTodoObservable(ofTodo todo: TodoModel) -> Observable<Bool> {
        guard let idx = todo.idx                             else { return .just(false) }
        guard let edittedText = self.addTextRelay.value      else { return .just(false) }
        guard let edittedDate = self.selectDateRelay.value   else { return .just(false) }
        guard let edittedJourney = self.dropdownRelay.value  else { return .just(false) }
        guard let edittedFixOnTop = self.fixOnTopRelay.value else { return .just(false) }
        
        let todoEditAPI = TodoAPI.editTodo(
            idx: idx,
            title: edittedText,
            date: edittedDate.convertToString(),
            journeyIdx: edittedJourney.idx,
            isTop: edittedFixOnTop
        )
        return NetworkManager.request(apiType: todoEditAPI)
            .asObservable()
            .map { (responseModel: TodoModel) in
                return true
            }
    }
    
    private func editJourneyObservable(ofJourney journey: WeekJourneyModel) -> Observable<Bool> {
        guard let idx = journey.idx                          else { return .just(false) }
        guard let edittedText = self.addTextRelay.value      else { return .just(false) }
        guard var journeySet = self.selectJourneyRelay.value else { return .just(false) }
        
        let firstJourney  = journeySet.removeFirst().rawValue
        let secondJourney = journeySet.isEmpty == false ? journeySet.removeFirst().rawValue : nil
        
        let journeyEditAPI = JourneyAPI.edittedJourney(
            idx: idx,
            title: edittedText,
            value1: firstJourney,
            value: secondJourney
        )
        return NetworkManager.request(apiType: journeyEditAPI)
            .asObservable()
            .map { (journey: WeekJourneyModel) in
                return true
            }
    }
    
    private func deleteJourneyObservable() -> Observable<Bool> {
        guard let addMode = self.addMode                  else { return .just(false) }
        guard addMode.addOptions.contains(.deleteJourney) else { return .just(false) }
        
        guard let journeyIDx = self.journey?.idx else { return .just(false) }
            
        let deleteJourneyAPI = JourneyAPI.deleteJourney(idx: journeyIDx)
        return NetworkManager.request(apiType: deleteJourneyAPI)
            .asObservable()
            .map { (successModel: SuccessModel) in
                return successModel.isSuccess == true
            }
    }
    
    private func bindEnableFlag(by addOptions: AddTodoVC.AddOptions) {
        if addOptions == .perDayAddTodo {
            Observable.combineLatest(self.addTextRelay, self.dropdownRelay, self.fixOnTopRelay)
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
            Observable.combineLatest(self.addTextRelay, self.selectDateRelay, self.fixOnTopRelay)
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
        } else if addOptions == .addJourney || addOptions == .edittedJourney {
            Observable.combineLatest(self.addTextRelay, self.selectJourneyRelay)
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
            Observable.combineLatest(self.addTextRelay, self.dropdownRelay, self.selectDateRelay, self.fixOnTopRelay)
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
    
    private var journey: WeekJourneyModel? {
        switch self.addMode {
        case .addJourneyTodo(let journey):
            return journey
            
        case .editJourney(let journey):
            return journey
            
        default:
            return nil
        }
    }
    
    private let disposeBag = DisposeBag()
    
    private let viewEventRelay = PublishRelay<ViewEvent>()
    private let addModeRelay = BehaviorRelay<AddTodoVC.AddMode?>(value: nil)
    
}

extension AddTodoViewModel {
    
    enum ViewEvent {
        case didTapAddButton
        case didTapDeleteJourney
    }
    
}
