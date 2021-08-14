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
            self?.updateJourneyList(journeyListModel)
        }, onFailure: { [weak self] _ in
            self?.updateJourneyList([])
        }).disposed(by: self.disposeBag)
    }
    
    private func updateJourneyList(_ list: [JourneyTitleModel]) {
        defer {
            let defaultMenu = self.journeyListRelay.value.first(where: { $0.title == "default" })
            self.selectedMenu.onNext(defaultMenu)
        }
        
        guard list.isEmpty == true else { self.journeyListRelay.accept(list); return }
        
        // 리스트가 비어 있는 경우 임의로 Default 여정 만들어서 보여주기 - 서버 : 이현주와 협의
        let defaultList = [JourneyTitleModel(idx: nil, title: "default", year: nil, month: nil, weekNo: nil, userIdx: nil)]
        self.journeyListRelay.accept(defaultList)
    }
    
    private let disposeBag = DisposeBag()
    
}
