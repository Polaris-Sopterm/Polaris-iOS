//
//  PolarisTodoEmptyView.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/03/06.
//

import UIKit
import SnapKit

class PolarisTodoEmptyView: UIView {
    
    let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "imgEmptyTodo")
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "여정을 세워보세요"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "여정을 세우면 다음주 할 일을 보다 쉽게 관리할 수 있어요."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUIs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUIs() {
        self.addSubview(self.emptyImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subTitleLabel)
        self.backgroundColor = .clear
        
        self.emptyImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(62)
            make.width.equalTo(27)
            make.height.equalTo(23)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.emptyImageView.snp.bottom).offset(12)
        }
        
        self.subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(3)
        }
    }
}
