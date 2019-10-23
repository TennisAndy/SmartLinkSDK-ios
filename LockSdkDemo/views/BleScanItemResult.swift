//
//  BleScanItemResult.swift
//  WunuLockDemo
//
//  Created by Iwunu on 2019/10/14.
//  Copyright © 2019年 WUNU. All rights reserved.
//

import Foundation
import UIKit

class BleScanItemResultView: UITableViewCell {
    
    var lockNameLabel: UILabel!
    var lockRSSILabel: UILabel!
    var lockFpLabel: UILabel!
    var lockNbLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        lockNameLabel = UILabel()
        lockRSSILabel = UILabel()
        lockFpLabel = UILabel()
        lockNbLabel = UILabel()
        
        lockFpLabel.text = "含指纹"
        lockNbLabel.text = "含NB"
        
        lockRSSILabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
        lockFpLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
        lockNbLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
    
        contentView.addSubview(lockNameLabel)
        contentView.addSubview(lockRSSILabel)
        contentView.addSubview(lockFpLabel)
        contentView.addSubview(lockNbLabel)
        
        lockNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lockRSSILabel.translatesAutoresizingMaskIntoConstraints = false
        lockFpLabel.translatesAutoresizingMaskIntoConstraints = false
        lockNbLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let viewsDict = [
            "lockFpLabel" : lockFpLabel,
            "lockNameLabel" : lockNameLabel,
            "lockRSSILabel" : lockRSSILabel,
            "lockNbLabel" : lockNbLabel]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[lockFpLabel(50)]-|", options: [], metrics: nil, views: viewsDict as [String : Any]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[lockNbLabel(50)]-|", options: [], metrics: nil, views: viewsDict as [String : Any]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lockFpLabel]-[lockNbLabel]-|", options: [], metrics: nil, views: viewsDict as [String : Any]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lockNameLabel]-[lockRSSILabel]-|", options: [], metrics: nil, views: viewsDict as [String : Any]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[lockNameLabel]-[lockFpLabel]-|", options: [], metrics: nil, views: viewsDict as [String : Any]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[lockRSSILabel]-[lockNbLabel]-|", options: [], metrics: nil, views: viewsDict as [String : Any]))
    }
    
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
