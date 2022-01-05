//
//  LookBackFifthTableViewCell.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/01/03.
//

import UIKit

class LookBackFifthTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var xButton: UIButton!
    
    private var index: Int?
    private var viewModel: LookBackViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUIs()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setUIs() {
        self.backgroundColor = .clear
        
        self.containerView.backgroundColor = .white15
        self.containerView.makeRounded(cornerRadius: 16)
        
        self.label.textColor = .white
        self.label.font = UIFont.systemFont(ofSize: 16)
        
        self.xButton.setTitle("", for: .normal)
    }
    
    func setText(text: String) {
        self.label.text = text
    }
    
    func setIndex(index: Int) {
        self.index = index
    }
    
    func setViewModel(viewModel: LookBackViewModel) {
        self.viewModel = viewModel
    }
    
    @IBAction func xButtonAction(_ sender: Any) {
        guard let index = self.index,
              let removeReason = self.label.text
        else { return }
        self.viewModel?.removeFifthvcReason(removeReason: removeReason)
    }
    
}
