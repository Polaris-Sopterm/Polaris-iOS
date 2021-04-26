//
//  MainTodoTVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/25.
//

import UIKit

class MainTodoTVC: UITableViewCell {
    @IBOutlet weak var wholeCV: UICollectionView!
    
    private var currentIndex: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUIs()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUIs(){
        self.wholeCV.dataSource = self
        self.wholeCV.delegate = self
        self.wholeCV.decelerationRate = .fast
        
        let layout = self.wholeCV.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0
        
        layout.itemSize = CGSize(width: DeviceInfo.screenWidth, height: DeviceInfo.screenHeight-285*(DeviceInfo.screenHeight/812.0))
        
        
        self.wholeCV.registerCell(cell: MainTodoCVC.self)
        self.backgroundColor = .clear
        self.wholeCV.backgroundColor = .clear
    }
    
    
}


extension MainTodoTVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: MainTodoCVC.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MainTodoCVC
       
        return cell
    }
}

extension MainTodoTVC: UICollectionViewDelegateFlowLayout {

}

extension MainTodoTVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == wholeCV {
            let layout = self.wholeCV.collectionViewLayout as! UICollectionViewFlowLayout
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
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       

    }
}
