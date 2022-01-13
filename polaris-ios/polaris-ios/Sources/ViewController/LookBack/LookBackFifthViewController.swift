//
//  LookBackFifthViewController.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/01/03.
//

import UIKit
import Combine

class LookBackFifthViewController: UIViewController, LookBackViewModelProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var textView: LookbackTextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var topYPosConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewYPosConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewYPosConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonYPosConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    let deviceHeightRatio = DeviceInfo.screenHeight/812.0
    
    private var viewModel = LookBackViewModel()
    private var pageDelegate: LookBackPageDelegate?
    private var dataSource: DataSource?
    private var reasonSubscription: AnyCancellable?
    private var nextButtonSubscription: AnyCancellable?
    
    typealias DataSource = UITableViewDiffableDataSource<Section, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIs()
        self.setUpDataSource()
        self.viewModel.publishFifthReasonInfo()
        // Do any additional setup after loading the view.
    }
    
    private func setUIs() {
        self.titleLabel.textColor = .maintext
        self.titleLabel.setPartialBold(originalText: "한 주 동안 ‘불편, 아쉬움’을\n느낀 이유는 무엇인가요?", boldText: "‘불편, 아쉬움’", fontSize: 22, boldFontSize: 22)
        self.subTitleLabel.textColor = .maintext

        self.textView.makeRounded(cornerRadius: 16)
        self.textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.textView.delegate = self
        self.placeholderSetting()
        
        self.tableView.backgroundColor = .clear
        self.tableView.registerCell(cell: LookBackFifthTableViewCell.self)
        self.tableView.delegate = self
        
        self.nextButton.setTitle("", for: .normal)
        self.nextButton.setImage(UIImage(named: "btnNextDisabled"), for: .normal)
//        self.nextButton.isEnabled = false
    }
    
    private func setUpDataSource() {
        self.dataSource = UITableViewDiffableDataSource(tableView: self.tableView, cellProvider: { (tableView, indexPath, string) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "LookBackFifthTableViewCell",for: indexPath) as! LookBackFifthTableViewCell
            cell.setText(text: string)
            cell.setIndex(index: indexPath.item)
            cell.setViewModel(viewModel: self.viewModel)
            return cell
        })
        
        self.reasonSubscription = viewModel.$fifthvcReason
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { reasons in
                self.updateReasons(reasons: reasons)
            })
        self.nextButtonSubscription = viewModel.$fourthvcNextButtonAble
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { value in
                if value {
                    self.nextButton.setImage(UIImage(named: "btnNextEnabled"), for: .normal)
                    self.nextButton.isEnabled = true
                }
                else {
                    self.nextButton.setImage(UIImage(named: "btnNextDisabled"), for: .normal)
                    self.nextButton.isEnabled = false
                }
            })
    }
    
    private func updateReasons(reasons: [String]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(reasons)
        guard let dataSource = self.dataSource else {
            return
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func placeholderSetting() {
        self.textView.text = "한 주 동안 있었던 일 적어보기"
        self.textView.textColor = UIColor.lightGray
    }
    
    func setViewModel(viewModel: LookBackViewModel) {
        self.viewModel = viewModel
    }
    
    func setPageDelegate(delegate: LookBackPageDelegate) {
        self.pageDelegate = delegate
    }
    
    
    @IBAction func nextButtonAction(_ sender: Any) {
        self.viewModel.toNextPage()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        guard let reason = self.textView.text else { return }
        
        if self.checkValidReason(reason: reason) {
            self.viewModel.addFifthvcReason(reason: reason)
        }
        self.textViewHeightConstraint.constant = 53
        self.placeholderSetting()
    }
    
    private func checkValidReason(reason: String) -> Bool {
        
        var pureString = reason.replacingOccurrences(of: " ", with: "")
        pureString = pureString.replacingOccurrences(of: "\n", with: "")
        guard reason != "한 주 동안 있었던 일 적어보기",
              pureString != ""
              
              
        else { return false }
        
        return true
    }
    
}

extension LookBackFifthViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension LookBackFifthViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .maintext
        }
        
    }
    func textViewDidChange(_ textView: UITextView) {
        let width: CGFloat         = DeviceInfo.screenWidth
        let horizonMargin: CGFloat = 24 + 24
        let textViewSize           = CGSize(width: width - (2 * horizonMargin), height: .infinity)
        let estimatedSize          = textView.sizeThatFits(textViewSize)
        
        self.textViewHeightConstraint.constant = max(53, estimatedSize.height)
        self.view.layoutIfNeeded()
    }
    
    
}
