//
//  TodoCellProtocol.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/18.
//

import UIKit

protocol TodoListModelProtocol { }

protocol TodoHeaderViewDelegate: AnyObject { }
protocol TodoCategoryCellDelegate: AnyObject { }

class TodoHeaderView: UIView {
    
    weak var delegate: TodoHeaderViewDelegate?
    class var headerHeight: CGFloat { return 0 }
    
}

class TodoCategoryCell: UITableViewCell {
    
    class var cellHeight: CGFloat { return 0 }
    weak var delegate: TodoCategoryCellDelegate?
    
    var indexPath: IndexPath?
    
    func configure(_ todoListModel: TodoListModelProtocol) {}
    func expandCell(isExpaned: Bool, animated: Bool) {}
    
}
