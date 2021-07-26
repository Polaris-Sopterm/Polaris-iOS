//
//  TodoCellProtocol.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/18.
//

import UIKit

protocol TodoListModelProtocol { }

protocol TodoHeaderViewDelegate: AnyObject { }

class TodoHeaderView: UIView {
    
    weak var delegate: TodoHeaderViewDelegate?
    class var headerHeight: CGFloat { return 0 }
    
}

class TodoCategoryCell: UITableViewCell {
    
    class var cellHeight: CGFloat { return 0 }
    
    func configure(_ todoListModel: TodoListModelProtocol) {}
    
}
