//
//  AddTodoTableViewCellProtocol.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit

protocol AddTodoTableViewCellProtocol: UITableViewCell {
    static var cellHeight: CGFloat { get }
    
    func configure(by addOptions: AddTodoVC.AddOptions)
}

class AddTodoTableViewCell: UITableViewCell, AddTodoTableViewCellProtocol {
    class var cellHeight: CGFloat { return 0 }
    
    func configure(by addOptions: AddTodoVC.AddOptions) { }
}
