//
//  JourneyTodoVC.swift
//  polaris-ios
//
//  Created by USER on 2021/05/16.
//

import UIKit

class JourneyTodoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationHeightConstraint.constant = 51 + DeviceInfo.topSafeAreaInset
    }
    
    @IBOutlet private weak var navigationHeightConstraint: NSLayoutConstraint!

}
