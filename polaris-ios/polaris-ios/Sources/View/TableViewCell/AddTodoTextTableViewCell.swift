//
//  AddTodoTextTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit
import RxSwift
import RxCocoa

class AddTodoTextTableViewCell: AddTodoTableViewCell {
    class override var cellHeight: CGFloat { return 100 }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    // MARK: - Bind
    private func bindTextField() {
        
    }
}