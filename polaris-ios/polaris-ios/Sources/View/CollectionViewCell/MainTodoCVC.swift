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
    
    private var colorNames = ["lightblue","bubblegumPink"]
    private let tempColor: UIColor = .black
    private var circleColors: [UIColor] = [] {
        didSet{
            if circleColors.count > 1 {
                for (idx,color) in upperColors.enumerated() {
                    color.backgroundColor = circleColors[idx]
                }
            }
        }
    }
    private var labelTexts: [String] = [] {
        didSet{
            if labelTexts.count > 1 {
                self.upperLabels[0].text = self.labelTexts[0]
                self.upperLabels[1].text = self.labelTexts[1]
                self.circleColors = [tempColor.changeJourneyToColor(journeyName: self.labelTexts[0]),tempColor.changeJourneyToColor(journeyName: self.labelTexts[1])]
            }
        }
    }
    
    var disposeBag = DisposeBag()
    
    var viewModel: MainTodoCVCViewModel? {
        didSet{
            self.labelTexts = viewModel?.valueRelay.value ?? []
            self.titleLabel.text = viewModel?.journeyNameRelay.value.last ?? ""
            self.viewModel?.todoListRelay.bind(to: todoTV.rx.items) { tableView, index, item in

                let identifier = String(describing: MainTodoTVC.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: IndexPath(item: index, section: 0)) as! MainTodoTVC
                cell.tvcViewModel = item
//                cell.setUIs(todoModel: item[index])
                return cell
            }.disposed(by: disposeBag)
        }
    }
    
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUIs()
        self.disposeBag = DisposeBag()
        // Initialization code
    
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
        for (idx,color) in self.upperColors.enumerated() {
            color.backgroundColor = .bubblegumPink
            color.makeRounded(cornerRadius: 6)
        }
        for (idx,label) in self.upperLabels.enumerated() {
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label.textColor = .maintext
        }
    }
}



extension MainTodoCVC: UITableViewDelegate{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
}
