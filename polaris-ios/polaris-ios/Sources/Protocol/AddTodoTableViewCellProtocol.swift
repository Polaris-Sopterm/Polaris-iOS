//
//  AddTodoTableViewCellProtocol.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit

protocol AddTodoTableViewCellProtocol: UITableViewCell {
    static var cellHeight: CGFloat { get }
}

class AddTodoTableViewCell: UITableViewCell, AddTodoTableViewCellProtocol {
    class var cellHeight: CGFloat { return 0 }
}
