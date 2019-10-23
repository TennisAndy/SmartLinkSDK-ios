//
//  CustomModalView.swift
//  WunuLockDemo
//
//  Created by Iwunu on 2019/10/17.
//  Copyright © 2019年 WUNU. All rights reserved.
//

import Foundation

import UIKit

class CustomModalView: UIView {
    
    //活动指示器
    var activity:UIActivityIndicatorView!
    //添加一个透明的View
    var activityView:UIView!
    
    var durationF:Double = 0.0
    
    var label:UILabel?
    
    
    //MARK: - 网络提示
    func initLoadingView(view:UIView, withText:String){
        
        activityView = UIView(frame:CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height))
        activityView.backgroundColor = UIColor.clear
        
        
        //配置
        self.frame = CGRect(x:(view.bounds.size.width/2 - 120/2), y:view.bounds.size.height/2 - 90/2, width:120,height:90)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.alpha = 0
        
        
        //配置
        activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.center = CGPoint(x:60, y: 30)
        activityView.addSubview(activity)
        self.addSubview(activity)
        
        
        //UILabel
        label = UILabel(frame:CGRect(x:0, y:50, width:120,height:30))
        label!.text = withText
        label!.font = UIFont.systemFont(ofSize: 14)
        label!.textAlignment = .center
        label!.textColor = UIColor.white
        self.addSubview(label!)
        
        
        activityView.addSubview(self)
        view.addSubview(activityView)
        activityView.isHidden = true
        
        
    }
    
    //显示菊花
    func startLoading(){
        
        activityView.isHidden = false
        activity.startAnimating()
        
        weak var weakSelf = self
        
        UIView.animate(withDuration: 0.3) {
            weakSelf?.alpha = 1
        }
    }
    
    
    //隐藏菊花
    func hideLoading(){
        if(activityView == nil){
            return
        }
        
        activityView.isHidden = true
        activity.stopAnimating()
        
        weak var weakSelf = self
        
        UIView.animate(withDuration: 0.3, animations: {
            weakSelf?.alpha = 0
        }) { (finish) in
            self.label?.removeFromSuperview()
            weakSelf?.activityView.isHidden = true
            weakSelf?.removeFromSuperview()
        }
    }
    
    
    
    //MARK: - 普通提示
    func initToast(view:UIView, text:String ,duration:Double){
        
        print(text)
        
        durationF = duration
        
        //适配高度
        let size:CGRect =  text.boundingRect(with: CGSize(width: view.bounds.width - 60, height: 400), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)] , context: nil);
        
        //配置
        self.frame = CGRect(x:(view.bounds.size.width/2 - (size.width + 20)/2), y:view.bounds.size.height/2 - 50/2, width:size.width + 20,height:50)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.alpha = 0
        
        
        //UILabel
        let label = UILabel(frame:CGRect(x:0, y:0, width: 120,height:50))
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        
        self.addSubview(label)
        view.addSubview(self)
        
        weak var weakSelf = self
        
        UIView.animate(withDuration: 0.3, animations: {
            
            weakSelf?.alpha = 1
            
        }) { (finish) in
            
            weakSelf?.perform(#selector(weakSelf?.closeCust), with: nil, afterDelay: (weakSelf?.durationF)!)
            
        }
        
        
    }
    
    //关闭
    @objc func closeCust(){
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.alpha = 0
            
        }) { (finished:Bool) in
            
            self.removeFromSuperview()
        }
    }
}
