//
//  LookBackPageViewController.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/12/26.
//

import UIKit

@objc class KVOObject : NSObject {
    @objc dynamic var curPresentViewIndex: Int = 0
    
}

class LookBackPageViewController: UIPageViewController {

    let identifiers = ["LookBackFirstViewController", "LookBackSecondViewController", "LookBackThirdViewController", "LookBackFourthViewController", "LookBackFifthViewController", "LookBackSixthViewController"]
   
    var previousPage: UIViewController?
    var nextPage: UIViewController?
    var realNextPage: UIViewController?
    var viewModel: LookBackViewModel?
    var keyValue = KVOObject()
    
    lazy var VCArray : [UIViewController] = {
        return [self.VCInstane(storyboardName: "LookBack", vcName: "LookBackFirstViewController"),
                self.VCInstane(storyboardName: "LookBack", vcName: "LookBackSecondViewController"),
                self.VCInstane(storyboardName: "LookBack", vcName: "LookBackThirdViewController"),
                self.VCInstane(storyboardName: "LookBack", vcName: "LookBackFourthViewController"),
                self.VCInstane(storyboardName: "LookBack", vcName: "LookBackFifthViewController"),
                self.VCInstane(storyboardName: "LookBack", vcName: "LookBackSixthViewController"),
        ]
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if let firstVC = VCArray.first{
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        guard let viewModel = self.viewModel else { return }
        for vc in VCArray {
            guard let viewModelVC = vc as? LookBackViewModelProtocol else { continue }
            viewModelVC.setViewModel(viewModel: viewModel)
        }
    }
    
    private func VCInstane(storyboardName : String, vcName : String) ->UIViewController{
        return UIStoryboard(name : storyboardName, bundle : nil).instantiateViewController(withIdentifier: vcName)
    }
}





extension LookBackPageViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIdx = VCArray.firstIndex(of: viewController) else {return nil}
        let prevIdx = vcIdx - 1
        
        if(prevIdx < 0){
            return nil
        }
        else{
            return VCArray[prevIdx]
        }
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIdx = VCArray.firstIndex(of: viewController) else {return nil}
        
        let nextIdx = vcIdx + 1

        if(nextIdx >= VCArray.count){
            return nil
        }
        else{
            return VCArray[nextIdx]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        nextPage = pendingViewControllers[0]
    }
}


