//
//  MainSceneTableViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/17.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit


enum StarCollectionViewState: Int, CaseIterable {
    case showStar = 1
    case showLookBack
    case showIncomplete
}


final class MainSceneTableViewCell: MainTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starCVCHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var starCV: UICollectionView!
    @IBOutlet weak var weekContainView: UIView!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var todoCV: UICollectionView!
    
    private var currentIndex: CGFloat = 0
    private var viewState = StarCollectionViewState.showStar
    private var lookBackState = MainLookBackCellState.lookback
    private var viewModel = MainSceneViewModel()
    private var starTVCViewModel: MainStarTVCViewModel?
    private var dataDriver: Driver<[MainStarCVCViewModel]>?
    private var homeModel: HomeModel?
    private var starList: [MainStarCVCViewModel] = [] {
        didSet{
            self.setTitle(stars: self.starList.count,lookBackState: self.lookBackState)
        }
    }
    private let disposeBag = DisposeBag()
    private let starTVCHeight = 212*(DeviceInfo.screenHeight/812.0)
    override static var cellHeight: CGFloat { return DeviceInfo.screenHeight }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUIs()
        self.setStarCollectionView()
        self.setTodoCollectionView()
        self.bindViewModel()
        self.setupDimView()
    }
    
    func updateDimView(alpha: CGFloat) {
        self.dimView.alpha = alpha
        if alpha == 0 { self.dimView.isHidden = true }
        else          { self.dimView.isHidden = false }
    }
    
    private func setupDimView() {
        self.dimView.frame           = CGRect(x: 0, y: 0,
                                              width: DeviceInfo.screenWidth, height: type(of: self).cellHeight)
        self.dimView.backgroundColor = .black
        self.dimView.alpha           = 0.0
        self.contentView.addSubview(self.dimView)
    }
    
    private var dimView: UIView = UIView(frame: .zero)
    
    func setUIs(){
        for _ in 0...2{
            self.cometAnimation()
        }
        self.weekContainView.backgroundColor = .white60
        self.weekContainView.setBorder(borderColor: .white, borderWidth: 1.0)
        self.weekContainView.makeRounded(cornerRadius: 9)
        self.weekLabel.font = UIFont.systemFont(ofSize: 13,weight: .bold)
        self.weekLabel.textColor = .white
        self.nowLabel.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        self.nowLabel.textColor = .white
        
        self.titleLabel.textColor = .white
        //        self.pageControl.frame.size.width = CGFloat(5) * 5 - 14
        if #available(iOS 14.0, *) {
            self.pageControl.backgroundStyle = .minimal
            self.pageControl.allowsContinuousInteraction = false
        }
    }
    
    
    
    func setStarCollectionView() {
        self.starCV.delegate = self
        self.starCV.registerCell(cell: MainStarCVC.self)
        self.starCV.registerCell(cell: MainLookBackCollectionViewCell.self)
        self.starCV.backgroundColor = .clear
    }
    
    func setTodoCollectionView() {
        self.todoCV.registerCell(cell: MainTodoCVC.self)
        self.todoCV.backgroundColor = .clear
        self.todoCV.delegate = self
        let layout = self.todoCV.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: DeviceInfo.screenWidth, height: DeviceInfo.screenHeight-285*(DeviceInfo.screenHeight/812.0))
    }
    
    func setTitle(stars: Int,lookBackState: MainLookBackCellState) {
        self.titleLabel.setPartialBold(originalText: "어제는\n\(stars)개의 별을 발견했어요.", boldText: "\(stars)개의 별", fontSize: 23, boldFontSize: 23)
    }
    
    private func bindViewModel(){
        let input = MainSceneViewModel.Input()
        let output = viewModel.connect(input: input)
        output.homeModelRelay.subscribe(onNext: { homeModel in
            self.homeModel = homeModel.last
        })
        .disposed(by: disposeBag)
        
        output.starList.subscribe(onNext: { item in
            self.starList = item
        })
        .disposed(by: disposeBag)
    
        output.state.subscribe(onNext: { value in
            self.viewState = value[0]
        })
        .disposed(by: disposeBag)
        
        output.lookBackState.subscribe(onNext: { value in
            self.lookBackState = value[0]
        })
        .disposed(by: disposeBag)
    
        output.state.subscribe(onNext: { state in
            self.viewState = state[0]
        }).disposed(by: disposeBag)
        
        output.mainTextRelay.subscribe(onNext: { text in
            self.titleLabel.setPartialBold(originalText: text, boldText: "", fontSize: 23, boldFontSize: 23)
        })
        .disposed(by: disposeBag)
        
        switch output.state.value[0] {
        case StarCollectionViewState.showStar:
            output.starList.bind(to: starCV.rx.items) { collectionView, index, item in
                let identifier = String(describing: MainStarCVC.self)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: 0)) as! MainStarCVC
                cell.cvcViewModel = item
                self.setTitle(stars: self.starList.count,lookBackState: self.lookBackState)
                return cell
            }.disposed(by: disposeBag)
            
        default :
            print(output.state.value)
//            self.setTitle(stars: self.starList.count,lookBackState: self.lookBackState)
            output.state.bind(to: starCV.rx.items){ collectionView, index, item in
                let identifier = String(describing: MainLookBackCollectionViewCell.self)
                let cell = self.starCV.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: 0)) as! MainLookBackCollectionViewCell
                
                if self.homeModel != nil {
                    cell.setState(state: self.lookBackState, bannerTitle: self.homeModel!.bannerTitle, bannerText: self.homeModel!.bannerText, buttonText: self.homeModel!.buttonText)
                }
                self.weekContainView.isHidden = true
                
                return cell
            }.disposed(by: disposeBag)
        }
        
        output.todoStarList.bind(to: todoCV.rx.items) { collectionView, index, item in
            let identifier = String(describing: MainTodoCVC.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: 0)) as! MainTodoCVC
            cell.viewModel = item
            self.pageControl.numberOfPages = output.todoStarList.value.count
            return cell
        }.disposed(by: disposeBag)
    }
    
    private func setCometLayout(comet: UIImageView,size: Int) {
        let heightConst = CGFloat(Int.random(in: 0...400))
        var width: CGFloat = 0.0
        if size == 0 {
            width = 70.0
        }
        else {
            width = 120.0
        }
        self.addSubview(comet)
        comet.translatesAutoresizingMaskIntoConstraints = false
        comet.leftAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        comet.bottomAnchor.constraint(equalTo: self.topAnchor,constant: heightConst).isActive = true
        comet.heightAnchor.constraint(equalToConstant: width).isActive = true
        comet.widthAnchor.constraint(equalToConstant: width).isActive = true
        
    }
    
    
    private func cometAnimation(){
        
        let cometImgNames = [ImageName.imgShootingstar,ImageName.imgShootingstar2]
        
        //        0: small, 1 : big
        let cometSize = Int.random(in: 0...1)
        let comet = UIImageView(image: UIImage(named: cometImgNames[cometSize]))
        
        setCometLayout(comet: comet, size: cometSize)
        let duration = Double(Int.random(in: 15...60))/10.0
        
        UIView.animate(withDuration: duration,delay:0.0, options:.curveEaseIn,animations: {
            comet.transform = CGAffineTransform(translationX: -DeviceInfo.screenWidth-120, y: DeviceInfo.screenWidth+120.0)
        },completion: { finished in
            comet.removeFromSuperview()
            self.cometAnimation()
        })
        
    }
    
}

extension MainSceneTableViewCell: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.starCV {
            if self.viewState == StarCollectionViewState.showStar {
                let starViewModel = self.starList
                return CGSize(width: starViewModel[indexPath.item].cellWidth, height: collectionView.frame.height)
            }
            else {
                return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            }
        }
        else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.starCV {
            if self.viewState == StarCollectionViewState.showStar {
                return 15
            }
            
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.starCV && self.viewState == StarCollectionViewState.showStar {
            
            switch self.starList.count {
            case 1 :
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
            case 2 :
                return UIEdgeInsets(top: 0, left: 93, bottom: 0, right: 30)
            case 3 :
                return UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 30)
                
            default :
                return UIEdgeInsets(top: 0, left: 38, bottom: 0, right: 30)
            }
        }
        else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}


extension MainSceneTableViewCell: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self.todoCV {
            let layout = self.todoCV.collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
            
            var offset = targetContentOffset.pointee
            let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
            var roundedIndex = round(index)
            
            if scrollView.contentOffset.x > targetContentOffset.pointee.x {
                roundedIndex = floor(index)
            } else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
                roundedIndex = ceil(index)
            } else {
                roundedIndex = round(index)
            }
            
            if currentIndex > roundedIndex {
                currentIndex -= 1
                roundedIndex = currentIndex
            } else if currentIndex < roundedIndex {
                currentIndex += 1
                roundedIndex = currentIndex
            }
            offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
            targetContentOffset.pointee = offset
            self.pageControl.currentPage = Int(self.currentIndex)
        }
    }
    
    
    
}




