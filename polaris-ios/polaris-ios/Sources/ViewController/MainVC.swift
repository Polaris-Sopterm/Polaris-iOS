//
//  MainVC.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/17.
//

import RxCocoa
import RxSwift
import UIKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.isMovingToParent || self.isBeingPresented else { return }
        self.scrollToMainSceneCell(animated: false)
    }
    
    func scrollToTodoListCell(animated: Bool = true) {
        let indexPath = IndexPath(row: MainSceneCellType.todoList.rawValue, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    func scrollToRetrospectCell(animated: Bool = true) {
        let indexPath = IndexPath(row: MainSceneCellType.retrospect.rawValue, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    func scrollToMainSceneCell(animated: Bool = true) {
        let indexPath = IndexPath(row: MainSceneCellType.main.rawValue, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    func pushRetrospectViewController() {
        let viewController = RetrospectReportVC.instantiateFromStoryboard(StoryboardName.main)
        
        guard let retropectVC = viewController else { return }
        self.navigationController?.pushViewController(retropectVC, animated: true)
    }
    
    private func registerCell() {
        MainSceneCellType.allCases.forEach { self.tableView.registerCell(cell: $0.cellType) }
    }
    
    private func setupTableView() {
        self.tableView.scrollsToTop = false
        self.tableView.dataSource   = self
        self.tableView.delegate     = self
        self.tableView.decelerationRate               = .fast
        self.tableView.contentInsetAdjustmentBehavior = .never
    }
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var tableView: UITableView!
    
}

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainSceneCellType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellType = MainSceneCellType(rawValue: indexPath.row)?.cellType,
              let mainCell = tableView.dequeueReusableCell(cell: cellType, forIndexPath: indexPath) else { return UITableViewCell() }
        
        return mainCell
    }
    
}

extension MainVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellType = MainSceneCellType(rawValue: indexPath.row)?.cellType else { return UITableView.automaticDimension }
        return cellType.cellHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = IndexPath(row: MainSceneCellType.main.rawValue, section: 0)
        
        guard let mainSceneCell = self.tableView.cellForRow(at: indexPath) as? MainSceneTableViewCell else { return }
        let alpha = abs(DeviceInfo.screenHeight - scrollView.contentOffset.y) / DeviceInfo.screenHeight
        mainSceneCell.updateDimView(alpha: alpha)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let estimatedPointee = targetContentOffset.pointee.y
        let estimatedPage    = Int(round(estimatedPointee / DeviceInfo.screenHeight))
        
        let estimatedContentOffsetY = CGFloat(estimatedPage) * DeviceInfo.screenHeight
        
        targetContentOffset.pointee = CGPoint(x: 0, y: estimatedContentOffsetY)
    }
    
}
