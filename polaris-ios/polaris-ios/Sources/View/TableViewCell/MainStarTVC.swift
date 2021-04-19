//
//  MainStarTVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import UIKit
import RxCocoa
import RxSwift

class MainStarTVC: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starCV: UICollectionView!
    
    var tvcViewModel = MainStarTVCViewModel()
    let disposeBag = DisposeBag()
    var starList: [MainStarCVCViewModel] = [] {
        didSet{
            self.tvcViewModel.starListRelay.accept(self.starList)
        }
        
    }
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUIs()
        self.bindViewModel()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUIs(){
        self.backgroundColor = .clear
        self.starCV.backgroundColor = .clear
        self.starCV.registerCell(cell: MainStarCVC.self)
        self.starCV.delegate = self
    }
    
    func setTitle(stars: Int) {
        let text = "어제는\n\(stars)개의 별을 발견했어요."
        let attributedString = NSMutableAttributedString(string: text)
        let font = UIFont(name:"AppleSDGothicNeo-Bold", size: 23)
        self.titleLabel.textColor = .white
        self.titleLabel.font = UIFont(name: "AppleSDGothicNeo-light", size: 23)
        attributedString.addAttribute(.font, value: font, range:(text as NSString).range(of: "\(stars)개의 별"))
        self.titleLabel.attributedText = attributedString
    }
    
    func bindViewModel(){
        let identifier = String(describing: MainStarCVC.self)
        
        self.tvcViewModel.starListRelay.bind(to: starCV.rx.items) { collectionView, index, item in
            let identifier = String(describing: MainStarCVC.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: 0)) as! MainStarCVC
            cell.cvcViewModel = item
            self.setTitle(stars: self.tvcViewModel.starListRelay.value.count)
            return cell
        }
        .disposed(by: self.disposeBag)
        
    }
    
    
    
}


extension MainStarTVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let starViewModel = tvcViewModel.starListRelay.value
        return CGSize(width: starViewModel[indexPath.item].cellWidth, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch self.tvcViewModel.starListRelay.value.count {
        case 1 :
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case 2 :
            return UIEdgeInsets(top: 0, left: 93, bottom: 0, right: 0)
        case 3 :
            return UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 0)
            
        default :
            return UIEdgeInsets(top: 0, left: 38, bottom: 0, right: 0)
        
        }
        
    }
    
}
