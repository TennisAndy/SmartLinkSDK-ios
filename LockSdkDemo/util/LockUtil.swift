//
//  LockUtil.swift
//  WunuLockDemo
//
//  Created by Iwunu on 2019/10/16.
//  Copyright © 2019年 WUNU. All rights reserved.
//

import Foundation

public func getLockModel( name: String) -> Int {
    
    if (name.count == 9) {
        return 1
    } else {
        let subIndex:String = (name as NSString).substring(with: NSMakeRange(5, 1))
        if (name.contains("WSL_A")) {
            return 1 + Int(subIndex)!
        } else if (name.contains("WSL_H")) {
            return 10 + Int(subIndex)!
        } else if (name.contains("WSL_B")) {
            return 21 + Int(subIndex)!
        } else if (name.contains("WSL_N")) {
            return 30 + Int(subIndex)!
        } else if (name.contains("WSL_M")) {
            return 40 + Int(subIndex)!
        } else if (name.contains("WSL_U")) {
            return 50 + Int(subIndex)!
        } else if (name.contains("WSL_J")) {
            return 60 + Int(subIndex)!
        } else if (name.contains("WSL_F")) {
            return 70 + Int(subIndex)!
        } else if (name.contains("WSL_C")) {
            return 80 + Int(subIndex)!
        } else if (name.contains("WSL_O")) {
            return 90 + Int(subIndex)!
        } else if (name.contains("WSL_D")) {
            return 100 + Int(subIndex)!
        } else if (name.contains("WSJ_Q")) {
            return 10000 + Int(subIndex)!
        } else {
            return 0
        }
    }
}

public func getLockType(model:Int) ->String{
    if (model > 0 && model <= 9) {
        return "蓝牙密码锁"
    } else if (model > 10 && model <= 19) {
        return "家庭锁系列"
    } else if (model > 20 && model <= 29) {
        return "酒店密码锁"
    } else if (model > 30 && model <= 49 || model > 100 && model <= 109) {
        return "蓝牙NB锁"
    } else if (model > 50 && model <= 59 || model > 90 && model <= 99) {
        return "蓝牙密码锁"
    } else if (model > 60 && model <= 69) {
        return "蓝牙NB机柜锁"
    } else if (model > 70 && model <= 79) {
        return "蓝牙指纹锁"
    } else if (model > 80 && model <= 89) {
        return "NB指纹锁"
    } else if (model > 10000 && model <= 10009) {
        return "取电开关"
    }else{
        return "蓝牙密码锁"
    }
}
