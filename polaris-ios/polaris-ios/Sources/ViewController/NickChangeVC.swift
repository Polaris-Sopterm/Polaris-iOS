//
//  NickChangeVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/08/23.
//

import UIKit

class NickChangeVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIs()
        // Do any additional setup after loading the view.
    }
    
    private func setUIs() {
        self.titleLabel.setPartialBold(originalText: "별명을\n변경해주세요", boldText: "별명", fontSize: 23.0, boldFontSize: 23.0)
        self.titleLabel.textColor = .maintext
        self.nickTextField.makeRounded(cornerRadius: 16.0)
        self.nickTextField.setBorder(borderColor: .inactiveText, borderWidth: 1.0)
        self.nickTextField.font = UIFont.systemFont(ofSize: 16.0)
        self.nickTextField.addLeftPadding(left: 26.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeButtonAction(_ sender: Any) {
        #warning("서버 아직 안나왔나?")
    }
}
