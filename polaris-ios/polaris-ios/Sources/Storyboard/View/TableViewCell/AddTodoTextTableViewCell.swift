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
    
    override weak var delegate: AddTodoTableViewCellDelegate? {
        didSet { _delegate = self.delegate as? AddTodoTextTableViewCellDelegate }
    }
    
    private weak var _delegate: AddTodoTextTableViewCellDelegate?
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTextFieldView()
    }
    
    override func configure(by addMode: AddTodoVC.AddMode, date: Date?) {
        super.configure(by: addMode, date: date)
        
        var addTodoCategory: AddTextCategory
        switch addMode {
        case .addJourneyTodo, .addDayTodo:
            addTodoCategory = .todo
            
        case .editTodo(let todo):
            addTodoCategory = .todo
            self.updateAddText(todo.title ?? "")
            
        case .editJourney(let journey):
            addTodoCategory = .journey
            self.updateAddText(journey.title ?? "")
            
        default:
            addTodoCategory = .journey
        }
        
        self.titleLabel.text = addTodoCategory.title
        self.polarisMarginTextFieldView?.setPlaceholder(text: addTodoCategory.placeHolder)
    }
    
    private func updateAddText(_ addText: String) {
        self.polarisMarginTextFieldView?.setText(addText)
        self._delegate?.addTodoTextTableViewCell(self, didChangeText: addText)
    }
    
    // MARK: - Set Up
    private func setupTextFieldView() {
        guard let polarisMarginTextFieldView = self.polarisMarginTextFieldView else { return }
        self.textFieldContainerView.addSubview(polarisMarginTextFieldView)
        self.polarisMarginTextFieldView?.delegate = self
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
            case .todo:     return "?????? ?????? ?????? ??????????"
            case .journey:   return "?????? ????????? ????????? ??????????"
            }
        }
        
        var placeHolder: String {
            switch self {
            case .todo:     return "????????? ?????? ???????????????."
            case .journey:   return "????????? ????????? ?????? ???????????????."
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
