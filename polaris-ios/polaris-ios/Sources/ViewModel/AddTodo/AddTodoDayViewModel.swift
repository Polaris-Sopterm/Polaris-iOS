//
//  AddTodoDayViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import Foundation
import RxSwift
import RxRelay

class AddTodoDayViewModel {
    
    var dates: [Date] {
        self.datesRelay.value
    }
    
    var datesObservable: Observable<[Date]> {
        self.datesRelay.asObservable()
    }
    
    var selectedDateObservable: Observable<Date?> {
        self.selectedDateRelay.asObservable()
    }
    
    func occur(viewEvent: ViewEvent) {
        switch viewEvent {
        case .configureForEdit(let todo):
            self.prepareDatesForEdit(todo: todo)
            
        case .selectCollectionView(let indexPath):
            self.selectDate(ofIndexPath: indexPath)
        
        }
    }
    
    private func prepareDatesForEdit(todo: TodoModel) {
        guard let todoDate = todo.date?.convertToDate()?.normalizedDate else { return }

        let weekDates = Date.datesIncludedInWeek(fromDate: todoDate)
        self.datesRelay.accept(weekDates)
        
        guard let todoDateIndex = weekDates.firstIndex(of: todoDate) else { return }
        let todoDateIndexPath = IndexPath(item: todoDateIndex, section: 0)
        self.selectDate(ofIndexPath: todoDateIndexPath)
    }
    
    private func updateDates(fromTodo todo: TodoModel) {
        guard let todoDate = todo.date?.convertToDate()?.normalizedDate else { return }
        
        let weekDates = Date.datesIncludedInWeek(fromDate: todoDate)
        self.datesRelay.accept(weekDates)
    }
    
    private func selectDate(ofIndexPath indexPath: IndexPath) {
        guard let selectedDate = self.dates[safe: indexPath.row] else { return }
        self.selectedDateRelay.accept(selectedDate)
    }
    
    private func selectDate(ofTodo todo: TodoModel) {
        
    }
    
    private let selectedDateRelay = BehaviorRelay<Date?>(value: nil)
    private let datesRelay = BehaviorRelay<[Date]>(value: Date.datesIncludedThisWeek)
    
}

extension AddTodoDayViewModel {
    
    enum ViewEvent {
        case configureForEdit(TodoModel)
        case selectCollectionView(indexPath: IndexPath)
    }
    
}
