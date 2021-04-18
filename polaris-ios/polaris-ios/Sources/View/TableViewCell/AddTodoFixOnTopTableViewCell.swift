//
//  AddTodoFixOnTopTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit
import RxSwift

class AddTodoFixOnTopTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat {
        return 100
    }
    
    @IBOutlet weak var notFixButton: UIButton!
    @IBOutlet weak var fixButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupButtons()
    }
    
    private func setupButtons() {
        self.notFixButton.makeRounded(cornerRadius: 15)
        self.fixButton.makeRounded(cornerRadius: 15)
    }
    
    static var selectedBackgroundColor: UIColor     = UIColor.inactiveSky
    static var unselectedBackgroundColor: UIColor   = UIColor.field
    
    static var selectedBorderColor: UIColor         = UIColor.mainSky
    static var unselectedBorderColor: UIColor       = UIColor.inactiveText
    
    var disposeBag = DisposeBag()
}
