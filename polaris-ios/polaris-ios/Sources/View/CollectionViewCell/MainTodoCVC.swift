//
//  MainTodoCVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/25.
//

import UIKit
import RxSwift
import RxCocoa

protocol MainTodoCollectionViewCellDelegate: AnyObject {
    func mainTodoCollectionViewCell(_ cell: MainTodoCVC, didTapDone todo: TodoModel)
}

class MainTodoCVC: UICollectionViewCell {
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var todoTV: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var journeyInfoViews: [UIView]!
    @IBOutlet var journeyColorViews: [UIView]!
    @IBOutlet var journeyValueLabels: [UILabel]!
    
    weak var delegate: MainTodoCollectionViewCellDelegate?
    
    var viewModel: MainTodoCVCViewModel? {
        didSet{
            guard let viewModel = self.viewModel else { return }
            self.updateJourneyUI(viewModel.journeyValues)
            self.titleLabel.text = viewModel.journeyTitle != "default" ? viewModel.journeyTitle : "여정이 없는 할 일"
            
            viewModel.todoListRelay.bind(to: todoTV.rx.items) { [weak self] tableView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                let cell = tableView.dequeueReusableCell(cell: MainTodoTVC.self, forIndexPath: indexPath)
                
                guard let mainTodoCell = cell else { return UITableViewCell() }
                mainTodoCell.todoModel = item.weekTodos
                mainTodoCell.delegate  = self
                return mainTodoCell
            }.disposed(by: disposeBag)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUIs()
    }
    
    private func setUIs(){
        self.upperView.backgroundColor = .white70
        self.upperView.makeRounded(cornerRadius: 22)
        self.backgroundColor = .clear
        self.todoTV.backgroundColor = .clear
        self.todoTV.delegate = self
        self.todoTV.registerCell(cell: MainTodoTVC.self)
        self.titleLabel.font = UIFont.systemFont(ofSize: 18,weight: .light)
        self.titleLabel.textColor = .maintext
        
        for info in self.journeyInfoViews{
            info.makeRounded(cornerRadius: 10)
            info.backgroundColor = UIColor(red: 64, green: 64, blue: 140, alpha: 0.1)
        }
        
        for (_, color) in self.journeyColorViews.enumerated() {
            color.backgroundColor = .bubblegumPink
            color.makeRounded(cornerRadius: 6)
        }
        
        for (_, label) in self.journeyValueLabels.enumerated() {
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label.textColor = .maintext
        }
    }
    
    private func updateJourneyUI(_ journey: [Journey]) {
        if let firstJourney = journey[safe: 0] {
            self.journeyInfoViews[safe: 0]?.isHidden         = false
            self.journeyValueLabels[safe: 0]?.text           = firstJourney.rawValue
            self.journeyColorViews[safe: 0]?.backgroundColor = firstJourney.color
        } else {
            self.journeyInfoViews[safe: 0]?.isHidden = true
        }
        
        if let secondJourney = journey[safe: 1] {
            self.journeyInfoViews[safe: 1]?.isHidden         = false
            self.journeyValueLabels[safe: 1]?.text           = secondJourney.rawValue
            self.journeyColorViews[safe: 1]?.backgroundColor = secondJourney.color
        } else {
            self.journeyInfoViews[safe: 1]?.isHidden = true
        }
    }
    
    private var disposeBag = DisposeBag()
    
}

extension MainTodoCVC: UITableViewDelegate{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
}

extension MainTodoCVC: MainTodoTableViewCellDelegate {
    
    func mainTodoTableViewCell(_ cell: MainTodoTVC, didTapDone todo: TodoModel) {
        self.delegate?.mainTodoCollectionViewCell(self, didTapDone: todo)
    }
    
}
