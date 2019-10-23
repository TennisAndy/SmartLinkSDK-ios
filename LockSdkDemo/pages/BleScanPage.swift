//
//  bleScan.swift
//  WunuLockDemo
//
//  Created by Iwunu on 2019/10/14.
//  Copyright © 2019年 WUNU. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class BleScanPage: UIViewController {
    
    var tableView: UITableView!
    
    private var devList: [CBPeripheral] = []

    private var devRssi: [CBPeripheral: Float] = [:]
    private var devAd: [CBPeripheral: NSObject] = [:]
    
    var isScanning: Bool = true
    var isBlueEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        self.title = "搜索蓝牙锁"
        
        self.tableView = UITableView(frame: view.bounds,style: UITableView.Style.plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(tableView)
        self.tableView?.register(BleScanItemResultView.self, forCellReuseIdentifier: "ResultCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        BluetoothManager.getInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(isBlueEnabled){
            self.title = "正在搜索..."
            BluetoothManager.getInstance().startScanPeripheral()
        }else{
            isScanning = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.title = "搜索蓝牙设备"
        BluetoothManager.getInstance().stopScanPeripheral()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        //case let vc as LockBindTableViewController:
        //    vc.peripheral = sender as? CBPeripheral
        default:
            print("\(self) of segue does not push !")
        }
    }
    
    
}

// MARK: - UITableViewDataSource
extension BleScanPage: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as! BleScanItemResultView
        
        let peripheral = self.devList[indexPath.row]
        cell.lockNameLabel.text = "智能锁: \(peripheral.name ?? "unknow")"
        cell.lockNameLabel.textColor = UIColor.black
        cell.lockRSSILabel.text = "信号强度: \(Int(devRssi[peripheral] ?? 0))"
        cell.lockFpLabel.isHidden = true
        cell.lockNbLabel.isHidden = true
        
        if(self.devAd[peripheral] != nil){
            let string = String(describing:self.devAd[peripheral])
            let chars = string[string.index(string.startIndex, offsetBy: 10)..<string.index(string.startIndex, offsetBy: 14)].cString(using: .utf8)
            //print("\(String(describing: peripheral.name)) chars: \(String(describing: chars))")
            cell.lockFpLabel.isHidden = !(chars?[0] == 49) //hasFp
            cell.lockNbLabel.isHidden = !((chars?[2] == 49) || (peripheral.name?.contains("WSL_N"))!)//hasNb

            if(chars?[3] == 49){ //bind
                cell.lockNameLabel.textColor = UIColor.red
            }
            if(chars?[1] == 49){ //light
                cell.lockNameLabel.textColor = UIColor.green
            }
        }
        
        if(((peripheral.name?.contains("WSL_N"))!)){ //为了兼容 旧版WSL_Nx无广播
            cell.lockNbLabel.isHidden = false//hasNb
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BleScanPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = self.devList[indexPath.row]
        print("连接：\(String(describing: peripheral.name))")
        self.title = "返回"
        
        let lockFunctionPage = LockFunctionPage()
        lockFunctionPage.peripheral = peripheral
        navigationController?.pushViewController(lockFunctionPage, animated: true)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension BleScanPage : BluetoothDelegate{
    // MARK: 检查运行这个App的设备是不是支持BLE。
    func didUpdateState(_ state: CBManagerState){
        if #available(iOS 10.0, *) {
            switch state {
            case CBManagerState.poweredOn:
                print("蓝牙打开")
                isBlueEnabled = true
                if(!isScanning){
                    self.title = "正在搜索..."
                    BluetoothManager.getInstance().startScanPeripheral()
                    isScanning = true
                }
            case CBManagerState.unauthorized:
                print("没有蓝牙功能")
            case CBManagerState.poweredOff:
                print("蓝牙关闭")
            default:
                print("未知状态")
            }
        }
    }
    
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber){
        //  因为iOS目前不提供蓝牙设备的UUID的获取，所以在这里通过蓝牙名称判断是否是本公司的设备
        if(RSSI.floatValue == 127) {return}
        
        if !self.devList.contains(peripheral) {
            self.devList.append(peripheral)
        }
        
        self.devRssi[peripheral] = RSSI.floatValue
        
        self.devAd[peripheral] = advertisementData[CBAdvertisementDataManufacturerDataKey] as? NSObject
        
        print("\(String(describing: peripheral.name)) 广播：\(String(describing: self.devAd[peripheral]))")
        
        //print("nearbyPeripherals count: \(nearbyPeripherals.count)")
        self.devList = self.devList.sorted(by: {(a:CBPeripheral, b:CBPeripheral) -> Bool in return self.devRssi[a]! > self.devRssi[b]!})
        self.tableView.reloadData()
    }
}





