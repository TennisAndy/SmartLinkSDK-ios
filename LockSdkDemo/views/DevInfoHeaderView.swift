//
//  DevInfoHeaderView.swift
//  WunuLockDemo
//
//  Created by Iwunu on 2019/10/16.
//  Copyright © 2019年 WUNU. All rights reserved.
//

import Foundation
import UIKit

class DevInfoHeaderView: UIView{
    
    var lockMacLabelLeft: UILabel!
    var lockTypeLabelLeft: UILabel!
    var lockMacLabelRight: UILabel!
    var lockTypeLabelRight: UILabel!
    
    fileprivate func initView() {
        lockMacLabelLeft = UILabel()
        lockTypeLabelLeft = UILabel()
        lockMacLabelRight = UILabel()
        lockTypeLabelRight = UILabel()
        
        lockMacLabelLeft.text = "设备MAC"
        lockTypeLabelLeft.text = "设备类型"
        lockMacLabelRight.text = "00:00:00:00:00:00"
        lockTypeLabelRight.text = "蓝牙密码锁"

        self.addSubview(lockMacLabelLeft)
        self.addSubview(lockTypeLabelLeft)
        self.addSubview(lockMacLabelRight)
        self.addSubview(lockTypeLabelRight)
        
        lockMacLabelLeft.translatesAutoresizingMaskIntoConstraints = false
        lockTypeLabelLeft.translatesAutoresizingMaskIntoConstraints = false
        lockMacLabelRight.translatesAutoresizingMaskIntoConstraints = false
        lockTypeLabelRight.translatesAutoresizingMaskIntoConstraints = false
        
        
        let viewsDict: [String : Any] = [
            "lockMacLabelLeft" : lockMacLabelLeft,
            "lockTypeLabelLeft" : lockTypeLabelLeft,
            "lockMacLabelRight" : lockMacLabelRight,
            "lockTypeLabelRight" : lockTypeLabelRight]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lockMacLabelLeft]", options: [], metrics: nil, views: viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lockMacLabelRight]", options: [], metrics: nil, views: viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lockMacLabelLeft]-(>=0)-[lockTypeLabelLeft]-|", options: [], metrics: nil, views: viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lockMacLabelRight]-(>=0)-[lockTypeLabelRight]-|", options: [], metrics: nil, views: viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[lockMacLabelLeft(100)]-(>=0)-[lockMacLabelRight]-|", options: [], metrics: nil, views: viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[lockTypeLabelLeft(100)]-(>=0)-[lockTypeLabelRight]-|", options: [], metrics: nil, views: viewsDict))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
}
