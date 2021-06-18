//
//  MainViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/17.
//

import Foundation
import RxRelay
import RxSwift

class MainViewModel {
    
    func update(page: MainSceneCellType) {
        self.currentPage = page
    }
    
    private(set) var currentPage: MainSceneCellType = .main
    
}
