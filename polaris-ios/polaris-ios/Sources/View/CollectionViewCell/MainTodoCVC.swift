//
//  MainTodoCVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/25.
//

import UIKit
import RxSwift
import RxCocoa

class MainTodoCVC: UICollectionViewCell {
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var todoTV: UITableView!
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var upperInfos: [UIView]!
    @IBOutlet var upperColors: [UIView]!
    @IBOutlet var upperLabels: [UILabel]!

    private var disposeBag = DisposeBag()
    
    var viewModel: MainTodoCVCViewModel? {
        didSet{
            guard let viewModel = self.viewModel else { return }
            self.updateJourneyUI(viewModel.journeyValues)
            self.titleLabel.text = viewModel.journeyTitle
            
            viewModel.todoListRelay.bind(to: todoTV.rx.items) { tableView, index, item in
                let identifier = String(describing: MainTodoTVC.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: IndexPath(item: index, section: 0)) as! MainTodoTVC
                cell.tvcModel = item.weekTodos
                return cell
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
        
        for info in self.upperInfos{
            info.makeRounded(cornerRadius: 10)
            info.backgroundColor = UIColor(red: 64, green: 64, blue: 140, alpha: 0.1)
            
        }
        for (_, color) in self.upperColors.enumerated() {
            color.backgroundColor = .bubblegumPink
            color.makeRounded(cornerRadius: 6)
        }
        for (_, label) in self.upperLabels.enumerated() {
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label.textColor = .maintext
        }
    }
    
    private func updateJourneyUI(_ journey: [Journey]) {
        self.upperInfos[safe: 1]?.isHidden = journey.count == 1
        
        if let firstJourney = journey[safe: 0] {
            self.upperLabels[safe: 0]?.text            = firstJourney.rawValue
            self.upperColors[safe: 0]?.backgroundColor = firstJourney.color
        }
        
        if let secondJourney = journey[safe: 1] {
            self.upperLabels[safe: 1]?.text            = secondJourney.rawValue
            self.upperColors[safe: 1]?.backgroundColor = secondJourney.color
        }
    }
}



extension MainTodoCVC: UITableViewDelegate{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
}
