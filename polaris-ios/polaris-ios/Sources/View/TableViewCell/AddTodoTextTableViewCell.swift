//
//  AddTodoTextTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit
import RxSwift
import RxCocoa

protocol AddTodoTextTableViewCellDelegate: AddTodoTableViewCellDelegate {
    func addTodoTextTableViewCell(_ addTodoTextTableViewCell: AddTodoTextTableViewCell, didChangeText text: String)
}

class AddTodoTextTableViewCell: AddTodoTableViewCell {
    class override var cellHeight: CGFloat {
        let textFieldHeight: CGFloat = (screenRaito * 53)
        let space: CGFloat           = 15
        let labelHeight: CGFloat     = 17
        return (verticalInset * 2) + space + textFieldHeight + labelHeight
    }
    
    override weak var delegate: AddTodoTableViewCellDelegate? { didSet { _delegate = self.delegate as? AddTodoTextTableViewCellDelegate } }
    weak var _delegate: AddTodoTextTableViewCellDelegate?
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupTextFieldView()
    }
    
    // MARK: - Set Up
    private func setupTextFieldView() {
        guard let polarisMarginTextFieldView = self.polarisMarginTextFieldView else { return }
        self.textFieldContainerView.addSubview(polarisMarginTextFieldView)
        self.polarisMarginTextFieldView?.delegate = self
    }
    
    override func configure(by addOptions: AddTodoVC.AddOptions, date: Date?) {
        var addTodoCategory: AddTextCategory
        if addOptions.contains(.perDayAddTodo) || addOptions.contains(.perJourneyAddTodo) {
            addTodoCategory = AddTextCategory.todo
        } else {
            addTodoCategory = AddTextCategory.journey
        }
        
        self.titleLabel.text = addTodoCategory.title
        self.polarisMarginTextFieldView?.setupPlaceholder(text: addTodoCategory.placeHolder)
    }
    
    private static let screenRaito: CGFloat         = DeviceInfo.screenWidth / 375
    private static let verticalInset: CGFloat       = 10
    
    private var polarisMarginTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textFieldContainerView: UIView!
    
}

extension AddTodoTextTableViewCell {
    enum AddTextCategory {
        case todo
        case journey
        
        var title: String {
            switch self {
            case .todo:     return "어떤 일을 해야 하나요?"
            case .journey:   return "어떤 여정을 떠나실 건가요?"
            }
        }
        
        var placeHolder: String {
            switch self {
            case .todo:     return "해야할 일을 적어주세요."
            case .journey:   return "이번주 목표한 일을 적어주세요."
            }
        }
    }
}

extension AddTodoTextTableViewCell: PolarisMarginTextFieldDelegate {
    
    func polarisMarginTextField(_ polarisMarginTextField: PolarisMarginTextField, didChangeText: String) {
        self._delegate?.addTodoTextTableViewCell(self, didChangeText: didChangeText)
    }
    
    func polarisMarginTextFieldDidTapReturn(_ polarisMarginTextField: PolarisMarginTextField) {}
    
}
