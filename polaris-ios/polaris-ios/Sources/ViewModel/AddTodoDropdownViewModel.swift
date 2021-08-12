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
    let selectedMenu     = BehaviorSubject<JourneyTitleModel?>(value: nil)
    let journeyListRelay = BehaviorRelay<[JourneyTitleModel]>(value: [])
    
    func requestJourneyList(_ date: Date?) {
        guard let date = date else { return }
        
        let journeyListAPI = JourneyAPI.jouneyTitleList(date: date.convertToString())
        NetworkManager.request(apiType: journeyListAPI).subscribe(onSuccess: { [weak self] (journeyListModel: [JourneyTitleModel]) in
            self?.journeyListRelay.accept(journeyListModel)
        }, onFailure: { [weak self] _ in
            self?.journeyListRelay.accept([])
        }).disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    
}
