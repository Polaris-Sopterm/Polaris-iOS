//
//  MainTodoCVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/25.
//

import UIKit

class MainTodoCVC: UICollectionViewCell {
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var todoTV: UITableView!
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var upperInfos: [UIView]!
    @IBOutlet var upperColors: [UIView]!
    @IBOutlet var upperLabels: [UILabel]!
    
    private var colorNames = ["lightblue","bubblegumPink"]
    private var labelTexts = ["성장","도전"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUIs()
        // Initialization code
    
    }

    private func setUIs(){
        self.upperView.backgroundColor = .white70
        self.upperView.makeRounded(cornerRadius: 22)
        self.backgroundColor = .clear
        self.todoTV.backgroundColor = .clear
        
        self.todoTV.registerCell(cell: TodoDateTVC.self)
        
        self.titleLabel.text = "폴라리스"
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
            print(idx)
            label.text = self.labelTexts[idx]
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label.textColor = .maintext
        }
        
    }
}

extension MainTodoCVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = String(describing: TodoDateTVC.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TodoDateTVC
      
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        3
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    
    
}

extension MainTodoCVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 58+30+35
        }
        
        return 49+58
    }
}
