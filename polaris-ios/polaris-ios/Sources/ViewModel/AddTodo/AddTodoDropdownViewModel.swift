//
//  AddTodoDropdownViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/19.
//

import Foundation
import RxSwift
import RxRelay

class AddTodoDropdownViewModel {
    
    let isExpanded       = BehaviorSubject<Bool>(value: false)
    let selectedMenu     = BehaviorRelay<JourneyTitleModel?>(value: nil)
    let journeyListRelay = BehaviorRelay<[JourneyTitleModel]>(value: [])
    
    init() {
        self.selectedMenu.accept(type(of: self).defaultJourney)
        self.journeyListRelay.accept([type(of: self).defaultJourney])
    }
    
    func requestJourneyList(_ date: Date?) {
        guard let date = date else { return }
        
        let journeyListAPI = JourneyAPI.jouneyTitleList(date: date.convertToString())
        NetworkManager.request(apiType: journeyListAPI).subscribe(onSuccess: { [weak self] (journeyListModel: [JourneyTitleModel]) in
            self?.updateJourneyList(journeyListModel)
        }, onFailure: { [weak self] _ in
            self?.updateJourneyList([])
        }).disposed(by: self.disposeBag)
    }
    
    func updateSelectedMenu(_ journey: JourneyTitleModel) {
        self.selectedMenu.accept(journey)
    }
    
    private func updateJourneyList(_ list: [JourneyTitleModel]) {
        let journeyList = list.isEmpty ? [type(of: self).defaultJourney] : list
        self.journeyListRelay.accept(journeyList)
    }
    
    private static let defaultJourney = JourneyTitleModel(idx: nil, title: "선택 안함",
                                                          year: nil, month: nil, weekNo: nil, userIdx: nil)
    
    private let disposeBag = DisposeBag()
    
}
