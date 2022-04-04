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
            
        case .configureForAddJourneyTodo(let journey):
            self.prepareDatesForAddJourneyTodo(journey: journey)
            
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
    
    private func prepareDatesForAddJourneyTodo(journey: WeekJourneyModel) {
        let polarisDate = PolarisDate(year: journey.year ?? 0, month: journey.month ?? 0, weekNo: journey.weekNo ?? 0)
        let weekDates = Date.datesIncludedInWeek(fromPolarisDate: polarisDate)
        self.datesRelay.accept(weekDates)
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
    
    private let selectedDateRelay = BehaviorRelay<Date?>(value: nil)
    private let datesRelay = BehaviorRelay<[Date]>(value: Date.datesIncludedThisWeek)
    
}

extension AddTodoDayViewModel {
    
    enum ViewEvent {
        case configureForEdit(TodoModel)
        case configureForAddJourneyTodo(WeekJourneyModel)
        case selectCollectionView(indexPath: IndexPath)
    }
    
}
