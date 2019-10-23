//
//  BluetoothManagerExtension.swift
//  WunuLockLib
//
//  Created by Iwunu on 2019/10/14.
//  Copyright © 2019年 WUNU. All rights reserved.
//

import CoreBluetooth

extension Array where Element == CBCharacteristic {
    func findCharacteristic(withUUID uuid: CBUUID) -> Element? {
        return self.first { $0.uuid.isEqual(uuid) }
    }
}
extension Array where Element == CBService {
    func findService(withUUID uuid: CBUUID) -> Element? {
        return self.first { $0.uuid.isEqual(uuid) }
    }
}
