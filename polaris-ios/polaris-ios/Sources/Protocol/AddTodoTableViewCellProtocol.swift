//
//  AddTodoTableViewCellProtocol.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit

protocol AddTodoTableViewCellDelegate: AnyObject {}

protocol AddTodoTableViewCellProtocol: UITableViewCell {
    static var cellHeight: CGFloat { get }
    var delegate: AddTodoTableViewCellDelegate? { get set }
    
    func configure(by addMode: AddTodoVC.AddMode, date: Date?)
}

class AddTodoTableViewCell: UITableViewCell, AddTodoTableViewCellProtocol {
    class var cellHeight: CGFloat { return 0 }
    weak var delegate: AddTodoTableViewCellDelegate?
    
    func configure(by addMode: AddTodoVC.AddMode, date: Date? = nil) { }
}
