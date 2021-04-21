//
//  MainSceneVC.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/18.
//

import UIKit
import RxSwift
import RxCocoa

class MainSceneVC: UIViewController {

    @IBOutlet weak var wholeTV: UITableView!
    
    
    let viewModel = MainSceneViewModel()
    var starTVCViewModel: MainStarTVCViewModel?
    var dataDriver: Driver<[MainStarCVCViewModel]>?
    var starList: [MainStarCVCViewModel] = [] {
        didSet{
            self.wholeTV.reloadData()
        }
    }
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIs()
        self.bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    func setUIs(){
        self.wholeTV.delegate = self
        self.wholeTV.dataSource = self
        self.wholeTV.registerCell(cell: MainStarTVC.self)
        self.wholeTV.backgroundColor = .clear
        
        for _ in 0...2{
            self.cometAnimation()
        }
       

    }
    
    private func bindViewModel(){
        let input = MainSceneViewModel.Input()
        let output = viewModel.connect(input: input)

        output.starList.subscribe(onNext: { item in
            self.starList = item
            
        })
        .disposed(by: disposeBag)


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
        self.view.addSubview(comet)
        comet.translatesAutoresizingMaskIntoConstraints = false
        comet.leftAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        comet.bottomAnchor.constraint(equalTo: self.view.topAnchor,constant: heightConst).isActive = true
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

extension MainSceneVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: MainStarTVC.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MainStarTVC
        
        cell.starList = self.starList

        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension MainSceneVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
}
