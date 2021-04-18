//
//  AddTodoTableViewCellProtocol.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit

protocol AddTodoTableViewCellProtocol {
    static var cellHeight: CGFloat { get }
}

class AddTotoTableViewCell: UITableViewCell, AddTodoTableViewCellProtocol {
    class var cellHeight: CGFloat { return 0 }
}
