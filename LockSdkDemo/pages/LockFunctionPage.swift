//
//  LockFunctionPage.swift
//  WunuLockDemo
//
//  Created by Iwunu on 2019/10/15.
//  Copyright © 2019年 WUNU. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import WunuLockLib

class LockFunctionPage: UIViewController {
    
    var devInfoHeader: DevInfoHeaderView?
    var customModal: CustomModalView?

    // 当前连接的设备
    var peripheral:CBPeripheral?
    
    //发送数据特征(连接到设备之后可以把需要用到的特征保存起来，方便使用)
    var sendCharacteristic:CBCharacteristic?
    
    var notifyCharacteristic:CBCharacteristic?
    
    var basecode:UInt32 = 20947807
    var lockId:UInt32 = 1
    var lockManagerId:UInt32 = 1
    
    var lockModel = 0
    var lockMac:String?
    var taskId = 0
    
    var pincode:UInt32 = 147258
    var pincodeIndex:UInt8 = 0
    
    var rfCardId:UInt32 = 2074946714
    var rfCardIndex:UInt8 = 0
    
    var fingerprintIndex:UInt8 = 0
    
    var isConnectInit = false
    var isLockLogin = false
    var isBindLock = false
    
    var isPincodeAdd = false
    var isRfCardAdd = false
    var isFingerprintAdd = false
    
    var isJack = false
    var isNbLock = false
    var isFpLock = false
    
    private var devList: [CBPeripheral] = []

    fileprivate func CGColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
            )
    }
    
    fileprivate func addButton(tag:Int, text:String , frame: CGRect) {
        let button = UIButton.init(frame: frame)
        button.tag = tag
        button.setTitle(text, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.gray, for: .disabled)
        button.backgroundColor = CGColorFromRGB(rgbValue: 0x26ab28)
        button.addTarget(self, action: #selector(self.buttonTap(button:)), for: UIControl.Event.touchUpInside)
        let bezierPath = UIBezierPath(roundedRect: button.bounds,byRoundingCorners: [.allCorners],cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = bezierPath.cgPath
        button.layer.mask = maskLayer;
        
        self.view.addSubview(button)
    }
    
    fileprivate func addDevInfo(){
        devInfoHeader = DevInfoHeaderView()
        devInfoHeader!.frame = CGRect.init(x: 0, y: 64, width: self.view.bounds.width, height: 80)
        devInfoHeader!.backgroundColor = UIColor.white
        devInfoHeader!.lockTypeLabelRight.text = getLockType(model: lockModel)
        self.view.addSubview(devInfoHeader!)
    }
    
    fileprivate func initViews() {
        var offsetY = 150
        let heightSpace = 65
        let width:Int = Int(self.view.bounds.width/2 - 30)
        let offSetX:Int = Int(self.view.bounds.width / 2 + 15)
        
        addButton(tag: 11, text: "绑定", frame: CGRect.init(x: 15, y: offsetY, width: width, height: 48))
        addButton(tag: 12, text: "解绑", frame: CGRect.init(x: offSetX, y: offsetY, width: width, height: 48))
        
        offsetY+=heightSpace
        addButton(tag: 21, text: "查询状态", frame: CGRect.init(x: 15, y: offsetY, width: width, height: 48))
        addButton(tag: 22, text: "查询电量", frame: CGRect.init(x: offSetX, y: offsetY, width: width, height: 48))
        
        offsetY+=heightSpace
        addButton(tag: 31, text: "查询IMEI", frame: CGRect.init(x: 15, y: offsetY, width: width, height: 48))
        addButton(tag: 32, text: "进登录态", frame: CGRect.init(x: offSetX, y: offsetY, width: width, height: 48))
        
        offsetY+=heightSpace
        addButton(tag: 41, text: "蓝牙解锁", frame: CGRect.init(x: 15, y: offsetY, width: width, height: 48))
        addButton(tag: 42, text: "同步时钟", frame: CGRect.init(x: offSetX, y: offsetY, width: width, height: 48))
        
        offsetY+=heightSpace
        addButton(tag: 51, text: "添加密码", frame: CGRect.init(x: 15, y: offsetY, width: width, height: 48))
        addButton(tag: 52, text: "删除密码", frame: CGRect.init(x: offSetX, y: offsetY, width: width, height: 48))
        
        offsetY+=heightSpace
        addButton(tag: 61, text: "添加房卡", frame: CGRect.init(x: 15, y: offsetY, width: width, height: 48))
        addButton(tag: 62, text: "删除房卡", frame: CGRect.init(x: offSetX, y: offsetY, width: width, height: 48))
        
        offsetY+=heightSpace
        addButton(tag: 71, text: "添加指纹", frame: CGRect.init(x: 15, y: offsetY, width: width, height: 48))
        addButton(tag: 72, text: "删除指纹", frame: CGRect.init(x: offSetX, y: offsetY, width: width, height: 48))
        
        offsetY+=heightSpace
        addButton(tag: 81, text: "修改管理密码", frame: CGRect.init(x: 15, y: offsetY, width: width, height: 48))
        addButton(tag: 82, text: "生成离线密码", frame: CGRect.init(x: offSetX, y: offsetY, width: width, height: 48))
    }
    
    fileprivate func updateUI(){
        (self.view.viewWithTag(11) as! UIButton).isEnabled = isConnectInit && !isBindLock
        (self.view.viewWithTag(12) as! UIButton).isEnabled = isConnectInit && isBindLock
        
        (self.view.viewWithTag(22) as! UIButton).isEnabled = isConnectInit && !isJack
        (self.view.viewWithTag(22) as! UIButton).isEnabled = isConnectInit && !isJack
        
        (self.view.viewWithTag(31) as! UIButton).isEnabled = isConnectInit && isNbLock
        (self.view.viewWithTag(32) as! UIButton).isEnabled = isConnectInit && isBindLock && lockModel > 70
        
        (self.view.viewWithTag(41) as! UIButton).isEnabled = isConnectInit && isBindLock
        (self.view.viewWithTag(42) as! UIButton).isEnabled = isConnectInit && isBindLock && !isJack
        
        (self.view.viewWithTag(51) as! UIButton).isEnabled = isConnectInit && isBindLock && !isJack && !isPincodeAdd
        (self.view.viewWithTag(52) as! UIButton).isEnabled = isConnectInit && isBindLock && !isJack && isPincodeAdd && !isJack
        
        (self.view.viewWithTag(61) as! UIButton).isEnabled = isConnectInit && isBindLock && !isJack && !isRfCardAdd && !isJack
        (self.view.viewWithTag(62) as! UIButton).isEnabled = isConnectInit && isBindLock && !isJack && isRfCardAdd && !isJack
        
        (self.view.viewWithTag(71) as! UIButton).isEnabled = isConnectInit && isBindLock && isFpLock && !isFingerprintAdd
        (self.view.viewWithTag(72) as! UIButton).isEnabled = isConnectInit && isBindLock && isFpLock && isFingerprintAdd
        
        (self.view.viewWithTag(81) as! UIButton).isEnabled = isConnectInit && isBindLock && lockModel > 70
        (self.view.viewWithTag(82) as! UIButton).isEnabled = isBindLock && lockModel > 70 && !isJack
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CGColorFromRGB(rgbValue: 0xf7f7f7)
        
        self.title = peripheral?.name
        lockModel = getLockModel(name: (peripheral?.name!)!)
        print("viewDidLoad lockModel = \(lockModel)")
        
        isJack = lockModel > 10000
        isNbLock = lockModel > 30 && lockModel < 50 || lockModel > 80 && lockModel < 90 || lockModel > 100 && lockModel < 110
        isFpLock = lockModel > 70 && lockModel < 90
        
        customModal = CustomModalView()
        addDevInfo()
        initViews()
        updateUI()
        
        BluetoothManager.getInstance().delegate = self
    }

    
    @objc func buttonTap(button:UIButton) {
        print("buttonTap参数 \(button.tag)")
        taskId = button.tag
        
        switch button.tag {
        case 11:
            customModal?.initLoadingView(view: self.view, withText: "绑定中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.sendBindLock(devName: (self.peripheral?.name!)!, lockId: self.lockId, managerId: self.lockManagerId, basecode: self.basecode)
            sendData(data:data)
            
        case 12:
            customModal?.initLoadingView(view: self.view, withText: "解绑中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.sendUnbindLock(devName: (self.peripheral?.name!)!, lockId: self.lockId, managerId: self.lockManagerId, basecode: self.basecode)
            sendData(data:data)
            
        case 21:
            customModal?.initLoadingView(view: self.view, withText: "查询中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.queryLockState(devName: (self.peripheral?.name!)!)
            sendData(data:data)
            
        case 22:
            customModal?.initLoadingView(view: self.view, withText: "查询中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.queryLockBattery(devName: (self.peripheral?.name!)!)
            sendData(data:data)
            
        case 31:
            customModal?.initLoadingView(view: self.view, withText: "查询中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.queryNbImei(devName: (self.peripheral?.name!)!)
            sendData(data:data)
            
        case 32:
            customModal?.initLoadingView(view: self.view, withText: "登录中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.login1(devName: (self.peripheral?.name!)!, basecode: self.basecode)
            sendData(data:data)
            
        case 41:
            customModal?.initLoadingView(view: self.view, withText: "开锁中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.sendOpenLockP1(devName: (self.peripheral?.name!)!, basecode: self.basecode)
            sendData(data:data)
            
        case 42:
            customModal?.initLoadingView(view: self.view, withText: "同步时钟中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.syncClock(devName: (self.peripheral?.name!)!, basecode: self.basecode, time: Date())
            sendData(data:data)
            
        case 51:
            customModal?.initLoadingView(view: self.view, withText: "添加密码中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.addPincode(devName: (self.peripheral?.name!)!, basecode: self.basecode, pincode: self.pincode, index: self.pincodeIndex, startTime: Date(), endTime: Date().addingTimeInterval(TimeInterval(300)))
            sendData(data:data)
            
        case 52:
            customModal?.initLoadingView(view: self.view, withText: "删除密码中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.delPincode(devName: (self.peripheral?.name!)!, basecode: self.basecode, pincode: self.pincode, index: self.pincodeIndex)
            sendData(data:data)
            
        case 61:
            customModal?.initLoadingView(view: self.view, withText: "添加房卡中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.addRfCard(devName: (self.peripheral?.name!)!, basecode: self.basecode, cardId: self.rfCardId, index: self.rfCardIndex, startTime: Date(), endTime: Date().addingTimeInterval(TimeInterval(300)))
            sendData(data:data)
            
        case 62:
            customModal?.initLoadingView(view: self.view, withText: "删除房卡中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.delRfCard(devName: (self.peripheral?.name!)!, basecode: self.basecode, cardId: self.rfCardId, index: self.rfCardIndex)
            sendData(data:data)

        case 71:
            customModal?.initLoadingView(view: self.view, withText: "添加指纹中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.addFingerprint(devName: (self.peripheral?.name!)!, basecode: self.basecode, index: self.fingerprintIndex, startTime: Date(), endTime: Date().addingTimeInterval(TimeInterval(300)))
            sendData(data:data)
            
        case 72:
            customModal?.initLoadingView(view: self.view, withText: "删除指纹中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.delFingerprint(devName: (self.peripheral?.name!)!, basecode: self.basecode, index: self.fingerprintIndex)
            sendData(data:data)
            
        case 81:
            customModal?.initLoadingView(view: self.view, withText: "修改中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.changeAdminPincode(devName: (self.peripheral?.name!)!, mac: lockMac!, oldPwd: 12345678, newPwd: 87654321)
            sendData(data:data)
            
        case 82:
            customModal?.initLoadingView(view: self.view, withText: "生成中")
            customModal?.startLoading()
            let data = LockCmdManager.shared.genOfflinePincode(devName: (self.peripheral?.name!)!, mac: lockMac!, basecode: self.basecode, pincodeType: 0, startTime: Date(), endTime: Date().addingTimeInterval(TimeInterval(300)))
            onReceiveData(data:data)
            
        default:
            _ = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BluetoothManager.getInstance().connectPeripheral(self.peripheral!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        BluetoothManager.getInstance().disconnectPeripheral()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendData(data:Data){
        BluetoothManager.getInstance().writeValue(data: data, forCharacteristic: self.sendCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    fileprivate func showAlertDialog(msg:String) {
        let alertController = UIAlertController(title: "提示", message: msg, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.destructive, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onReceiveData(data: [String : Any]){
        print("onReceiveData \(data)")
        if(data["code"]! as! Int == 404) {
            return
        }
        
        switch data["cmd"]! as! String {
            
        case "genOfflinePincode":
            let resultCode = data["code"]! as! Int
            customModal?.hideLoading()
            switch resultCode {
            case 200:
                let offlinePincode = (data["data"] as! [String: String])["password"] as! String
                showAlertDialog(msg: "生成的离线密码为 \(offlinePincode)")
            default:
                let msg = (data["data"] as? [String: Any])?["msg"] as? String
                showAlertDialog(msg: msg!)
                isRfCardAdd = false
                updateUI()
            }
            taskId = 0
            
        case "reportLockBattery":
            let battery = (data["data"]! as! [String:Any])["battery"] as! UInt8
                customModal?.hideLoading()
                showAlertDialog(msg: "门已上锁，此时电量：\(String(describing: battery))%")
                taskId = 0
            
        case "reportOtherUnlockResult":
            let isValid = (data["data"]! as! [String: Any])["isValid"] as! Bool
            if(isValid){
                let pincode = (data["data"]! as! [String: Any])["pincode"] as! UInt32
                showAlertDialog(msg: "其他密码：\(pincode)开锁成功！")
            }else{
                showAlertDialog(msg: "非法密码！")
            }
            taskId = 0
            
        case "reportRfCardResult":
            if(lockModel < 70){
                let isValid = (data["data"]! as! [String: Any])["isValid"] as! Bool
                let cardId = (data["data"]! as! [String: Any])["cardId"] as! UInt32
                if(isValid){
                    showAlertDialog(msg: "房卡：\(cardId)开锁成功！")
                }else{
                    showAlertDialog(msg: "非法房卡：\(cardId)！")
                }
            }else{
                let isValid = (data["data"]! as! [String: Any])["isValid"] as! Bool
                if(isValid){
                    let index = (data["data"]! as! [String: Any])["index"] as! UInt8
                    showAlertDialog(msg: "房卡序号：\(index)开锁成功！")
                }else{
                    showAlertDialog(msg: "非法房卡！")
                }
            }
            taskId = 0
            
        case "reportPincodeResult":
            if(lockModel < 70){
                let isValid = (data["data"]! as! [String: Any])["isValid"] as! Bool
                let pincode = (data["data"]! as! [String: Any])["pincode"] as! UInt32
                if(isValid){
                    showAlertDialog(msg: "密码：\(pincode)开锁成功！")
                }else{
                    showAlertDialog(msg: "非法密码：\(pincode)！")
                }
            }else{
                let isValid = (data["data"]! as! [String: Any])["isValid"] as! Bool
                if(isValid){
                    let index = (data["data"]! as! [String: Any])["index"] as! UInt8
                    showAlertDialog(msg: "密码序号：\(index)开锁成功！")
                }else{
                    showAlertDialog(msg: "非法房卡！")
                }
            }
            taskId = 0
            
        case "reportFingerprintResult":
            let isValid = (data["data"]! as! [String: Any])["isValid"] as! Bool
            if(isValid){
                let index = (data["data"]! as! [String: Any])["index"] as! UInt8
                showAlertDialog(msg: "指纹序号：\(index)开锁成功！")
            }else{
                showAlertDialog(msg: "非法房卡！")
            }
            taskId = 0
            
        case "queryLockState":
            lockMac = (data["data"]! as! [String: Any])["mac"] as! String
            devInfoHeader?.lockMacLabelRight.text = lockMac
            isBindLock = (data["data"]! as! [String: Any])["isBind"] as! Bool
            updateUI()
            print("isBindLock = \(isBindLock)")
            if(taskId != 0){
                customModal?.hideLoading()
                showAlertDialog(msg: "此设备绑定状态：\(String(describing: isBindLock))")
            }
            taskId = 0
            
        case "queryLockBattery":
            let battery = (data["data"]! as! [String:Any])["battery"] as! UInt8
            customModal?.hideLoading()
            showAlertDialog(msg: "此设备电量：\(String(describing: battery))%")
            taskId = 0
            
        case "queryNbImei":
            let imei = (data["data"]! as! [String: Any])["imei"] as! String
            customModal?.hideLoading()
            showAlertDialog(msg: "此NB设备IMEI：\(imei)")
            taskId = 0
            
        case "sendBindLock":
            let isSuccess = data["code"]! as! Int == 200
            customModal?.hideLoading()
            if(isSuccess){
                showAlertDialog(msg: "设备绑定成功!")
                isBindLock = true
                updateUI()
            }else{
                showAlertDialog(msg: "设备绑定失败!")
            }
            taskId = 0
            
        case "sendUnbindLock":
            let isSuccess = data["code"]! as! Int == 200
            customModal?.hideLoading()
            if(isSuccess){
                showAlertDialog(msg: "设备解绑成功!")
                isBindLock = false
                updateUI()
            }else{
                showAlertDialog(msg: "设备解绑失败!")
            }
            taskId = 0
            
        case "sendOpenLockP1":
            let isSuccess = data["code"]! as! Int == 200
            if(isSuccess){
                let randomN = (data["data"]! as! ([String : Any]))["randomN"]! as! UInt8
                if(taskId == 41){
                    let data = LockCmdManager.shared.sendOpenLockP2(devName: (self.peripheral?.name!)!, basecode: self.basecode, randomN: UInt32(randomN))
                    sendData(data:data)
                }else{
                    let data = LockCmdManager.shared.login2(devName: (self.peripheral?.name!)!, basecode: self.basecode, randomN: UInt32(randomN))
                    sendData(data:data)
                }
            }else{
                customModal?.hideLoading()
                showAlertDialog(msg: "解锁失败!")
                taskId = 0
            }
            
        case "login":
            let isSuccess = data["code"]! as! Int == 200
            customModal?.hideLoading()
            if(isSuccess){
                showAlertDialog(msg: "登录成功!")
            }else{
                showAlertDialog(msg: "登录失败!")
            }
            taskId = 0
            
        case "sendOpenLockP2":
            let isSuccess = data["code"]! as! Int == 200
            customModal?.hideLoading()
            if(isSuccess){
                showAlertDialog(msg: "解锁成功!")
            }else{
                showAlertDialog(msg: "解锁失败!")
            }
            taskId = 0
            
        case "syncClock":
            let isSuccess = data["code"]! as! Int == 200
            customModal?.hideLoading()
            if(isSuccess){
                showAlertDialog(msg: "同步成功!")
            }else{
                showAlertDialog(msg: "同步失败!")
            }
            taskId = 0
            
        case "changeAdminPincode":
            let isSuccess = data["code"]! as! Int == 200
            customModal?.hideLoading()
            if(isSuccess){
                showAlertDialog(msg: "修改成功!")
            }else{
                showAlertDialog(msg: "修改失败!")
            }
            taskId = 0
            
        case "addPincode":
            let resultCode = data["code"]! as! Int
            customModal?.hideLoading()
            switch resultCode {
                case 300:
                    let msg = (data["data"] as? [String: Any])?["msg"] as? String
                    showAlertDialog(msg: "添加失败! \(msg)")
            default:
                showAlertDialog(msg: "添加成功!")
                isPincodeAdd = true
                updateUI()
            }

            taskId = 0
            
        case "delPincode":
            let resultCode = data["code"]! as! Int
            customModal?.hideLoading()
            switch resultCode {
            case 300:
                let msg = (data["data"] as? [String: Any])?["msg"] as? String
                showAlertDialog(msg: "删除失败! \(msg)")
            default:
                showAlertDialog(msg: "删除成功!")
                isPincodeAdd = false
                updateUI()
            }

            taskId = 0

        case "addRfCard":
            let resultCode = data["code"]! as! Int
            customModal?.hideLoading()
            switch resultCode {
            case 300:
                let msg = (data["data"] as? [String: Any])?["msg"] as? String
                showAlertDialog(msg: "添加失败! \(msg)")
            case 100:
                let msg = (data["data"]! as! [String: Any])["msg"]! as! String
                print("msg: \(msg)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.customModal?.initLoadingView(view: self.view, withText: "\(msg)")
                    self.customModal?.startLoading()
                }
            default:
                showAlertDialog(msg: "添加成功!")
                isRfCardAdd = true
                updateUI()
            }
            taskId = 0
            
        case "delRfCard":
            let resultCode = data["code"]! as! Int
            customModal?.hideLoading()
            switch resultCode {
            case 300:
                let msg = (data["data"] as? [String: Any])?["msg"] as? String
                showAlertDialog(msg: "删除失败! \(msg)")
            default:
                showAlertDialog(msg: "删除成功!")
                isRfCardAdd = false
                updateUI()
            }
            taskId = 0

        case "addFingerprint":
            let resultCode = data["code"]! as! Int
            customModal?.hideLoading()
            switch resultCode {
            case 300:
                let msg = (data["data"] as? [String: Any])?["msg"] as? String
                showAlertDialog(msg: "添加失败! \(msg)")
            case 100:
                let msg = (data["data"]! as! [String: Any])["msg"]! as! String
                print("msg: \(msg)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.customModal?.initLoadingView(view: self.view, withText: "\(msg)")
                    self.customModal?.startLoading()
                }
            default:
                showAlertDialog(msg: "添加成功!")
                isFingerprintAdd = true
                updateUI()
            }
            taskId = 0
            
        case "delFingerprint":
            let resultCode = data["code"]! as! Int
            customModal?.hideLoading()
            switch resultCode {
            case 300:
                let msg = (data["data"] as? [String: Any])?["msg"] as? String
                showAlertDialog(msg: "删除失败! \(msg)")
            default:
                showAlertDialog(msg: "删除成功!")
                isFingerprintAdd = false
                updateUI()
            }
            taskId = 0

        default:
            _ = 1
        }
    }
}

extension LockFunctionPage : BluetoothDelegate{
    
    func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral){
        print("didConnectedPeripheral \(String(describing: peripheral))")
        self.title = connectedPeripheral.name! + " 已连接"
    }
    
    // MARK: 连接外设失败
    func failToConnectPeripheral(_ peripheral: CBPeripheral, error: Error) {
        // 这里可以发通知出去告诉设备连接界面连接失败
        print("didFailToConnect \(peripheral), error: \(error)")
        self.title = peripheral.name! + " 连接失败"
    }
    
    func didDisconnectPeripheral(_ peripheral: CBPeripheral){
        self.title = peripheral.name! + " 连接断开"
    }
    
    func didDiscoverServices(_ peripheral: CBPeripheral){
        print("didDiscoverServices \(String(describing: peripheral))")
        BluetoothManager.getInstance().discoverCharacteristics()
    }
    
    func didDiscoverCharacteritics(_ service: CBService){
        print("didDiscoverCharacteritics \(String(describing: service.characteristics?.count))")
        for  characteristic in service.characteristics! {
            print("扫描到特征 \(characteristic.uuid.description)")
            
            switch characteristic.uuid.description {
            case "FFF7":
                // 订阅特征值，订阅成功后后续所有的值变化都会自动通知
                self.notifyCharacteristic = characteristic
            case "FFF6":
                // 写区特征值
                self.sendCharacteristic = characteristic
            default:
                print("未处理 \(characteristic.uuid.description)")
            }
        }
        
        BluetoothManager.getInstance().setNotification(enable: true, forCharacteristic: self.notifyCharacteristic!)
    }
    
    func didUpdateNotificationStateFor(_ characteristic: CBCharacteristic){
        print("didUpdateNotificationStateFor \(String(describing: characteristic))")
        self.title = self.peripheral!.name! + " 已就绪"
        self.isConnectInit = true
        updateUI()
        sendData(data: LockCmdManager.shared.queryLockState(devName: (self.peripheral?.name!)!))
    }
    
    func didReadValueForCharacteristic(_ characteristic: CBCharacteristic){
        switch characteristic.uuid.uuidString {
        case "FFF7":
            print("接收:\(String(format: "%@", characteristic.value! as CVarArg))")
            let data = LockCmdManager.shared.parseBytes(devName: (self.peripheral?.name!)!, basecode: self.basecode, data: characteristic.value!)
            onReceiveData(data: data)
        default:
            print("收到了其他数据特征数据: \(characteristic.uuid.uuidString)")
        }
    }
}
