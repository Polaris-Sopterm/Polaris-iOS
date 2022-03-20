//
//  NotificationCenter+.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/03/20.
//

import Foundation

extension NotificationCenter {
    
    func postUpdateTodo(fromScene scene: MainSceneCellType) {
        self.post(name: .didUpdateTodo, object: scene.sceneIdentifier)
    }
    
}
