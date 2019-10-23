# 智能门锁ios sdk

此插件封装了智能锁蓝牙通信协议部分，通过接口函数轻松生成蓝牙指令，开发者只需将指令通过蓝牙发送出去，再解析指令回复获取结果。
>功能示例
>* 1.扫描锁蓝牙
![链接](./bleScan.jpg)
>* 2.WSL_Cx蓝牙指纹NB锁系列
![链接](./wsl_cx.jpg)

***
## 1.工程SDK配置

1.1 将WunuLockLib.framework包拖进工程目录，设置第三方库为Embed & Sign.

1.2 创建PodFile,添加依赖库
<pre><code>
target "LockSdkDemo" do 
  pod 'RxCocoa', '~> 4.1.2'
  pod 'SwiftyJSON', '<= 4.2.0'
end

swift_41_pod_targets = ['Rxcocoa']
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if swift_41_pod_targets.include?(target.name)
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end
</code></pre> 
1.3 申请sdk appkey
  发送邮件至logsoul@qq.com，申请appKey， 注明申请app主体信息，联系方式，bundleId，应用名称，应用说明，我们将于1～2个工作日处理。

1.4 插件初始化
<pre><code>
//初始化
let data = LockCmdManager.shared.initSdk(appId: "your bundleId", appKey: "your appKey")
print("initSdk: \(data)")
...
//生成指令
let data = LockCmdManager.shared.sendBindLock(devName: (self.peripheral?.name!)!, lockId: self.lockId, managerId: self.lockManagerId, basecode: self.basecode)
  sendData(data:data)
 ...
 //解析指令回复字典数据
 let data = LockCmdManager.shared.parseBytes(devName: (self.peripheral?.name!)!, basecode: self.basecode, data: characteristic.value!)
switch data["cmd"]! as! String {
  case "queryLockState":
    let lockMac = (data["data"]! as! [String: Any])["mac"] as! String
    let isBindLock = (data["data"]! as! [String: Any])["isBind"] as! Bool
}
</code></pre> 

***
## 2. 通用指令接口

### 2.1 指令回复解析 parseBytes
  >func parseBytes(devName:String, basecode:UInt32, data:Data) -> [String : Any]
  >* params: 
    >>devName: String类型，锁蓝牙名称，
    >>basecode: int类型，8位素数，用于蓝牙通信解密
    >>data: 接收到的蓝牙回复数据

  >* return 字典数据:
    >>cmd: String类型，函数接口名称，
    >>code: int类型，200表示指令返回预期结果，300表示指令错误
    >>data: 字典类型，指令返回数据。

>示例代码
![链接](./demoParseBytes.png)

### 2.2 查询门锁绑定状态及mac地址 queryLockState  
  >func queryLockState(devName:String) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称

  >* return data: 
    >>isBind: bool类型，表示锁硬件绑定状态，
    >>mac: String类型，表示锁的蓝牙MAC地址

### 2.3 查询门锁电量信息 queryLockBattery  
  >func queryLockBattery(devName:String) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称

  >* return data: 
    >>battery: int类型，表示锁电池电量百分比

  注意：开锁成功，会主动上报电量，主动上报接口名称为reportLockBattery。

### 2.4 绑定门锁 sendBindLock  
  >func sendBindLock(devName:String, lockId: UInt32, managerId: UInt32, basecode: UInt32) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>lockId: int类型，锁注册id
    >>managerId: int类型，锁管理员id
    >>basecode: int类型，8位素数，用于蓝牙通信加密，建议每一把锁提供不同的basecode

  >* return: 
    >>code: int类型，200表示绑定成功，300表示绑定失败

### 2.5 解绑门锁 sendUnbindLock  
  >func sendUnbindLock(devName:String, lockId: UInt32, managerId: UInt32, basecode: UInt32) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>lockId: int类型，锁注册id
    >>managerId: int类型，锁管理员id
    >>basecode: int类型，绑定时生成

  >* return: 
    >>code: int类型，200表示解绑成功，300表示解绑失败

### 2.6 蓝牙开锁 sendOpenLockP1/sendOpenLockP2 
  >func sendOpenLockP1(devName:String, basecode: UInt32) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码  

   >* return data: 
    >>randomN: int类型，解锁第二步加密参数

  >func sendOpenLockP2(devName:String, basecode: UInt32, randomN: UInt32) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码  
    >>randomN: int类型，解锁第一步返回

  >* return: 
    >>code: int类型，200表示蓝牙开锁成功，300表示蓝牙开锁失败

## 3. 蓝牙密码锁WSL_Ux，NB密码锁WSL_Nx和WSL_Mx系列锁指令接口

### 3.1 同步时钟 syncClock
  >func syncClock(devName: String, basecode: UInt32, time: Date) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>time: Date类型，本地时钟，例如中国为UTC+8时间

  >* return: 
    >>code: int类型，200表示同步时钟成功，300表示同步时钟失败
注意：当密码，刷卡无法开门，或重启后，需要更新时钟。  

### 3.2 添加限时密码 addPincode
  >func addPincode(devName: String, basecode: UInt32, pincode: UInt32, index:UInt8, startTime: Date, endTime: Date) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>pincode: int类型，6位开锁密码
    >>index: int类型，密码序号，0～99，不需要，传0
    >>startTime: Date类型，密码生效时间，取本地时钟，例如中国为UTC+8时间
    >>endTime: Date类型，密码失效时间，取本地时钟，例如中国为UTC+8时间

  >* return: 
    >>code: int类型，200表示添加成功，300表示添加失败 

  注意：密码开锁结果上报，接口名称reportPincodeResult，数据结构如下：
  {
    > pincode: int类型，表示开锁密码
    > time: date类型，表示开锁时间
    > type: int类型, 表示密码类型
    > isValid: bool类型，表示密码是否开锁成功
  }   

### 3.3 删除限时密码 delPincode
  >func delPincode(devName: String, basecode: UInt32, pincode: UInt32, index:UInt8) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>pincode: int类型，6位开锁密码
    >>index: int类型，密码序号，0～99，不需要，传0

  >* return: 
    >>code: int类型，200表示删除成功，300表示删除失败     

### 3.4 添加限时房卡 addRfCard
  >func addRfCard(devName: String, basecode: UInt32, cardId: UInt32, index:UInt8, startTime: Date, endTime: Date) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>cardId: int类型，房卡卡号
    >>index: int类型，房卡序号，0～99，不需要，传0
    >>startTime: Date类型，房卡生效时间，取本地时钟，例如中国为UTC+8时间
    >>endTime: Date类型，房卡失效时间，取本地时钟，例如中国为UTC+8时间

  >* return: 
    >>code: int类型，200表示添加成功，300表示添加失败    

  注意：刷卡开锁结果上报，接口名称reportRfCardResult，数据结构如下：
  {
    > cardId: int类型，表示房卡卡号
    > time: date类型，表示开锁时间
    > type: int类型, 表示房卡类型
    > isValid: bool类型，表示房卡是否开锁成功
  } 
  
### 3.5 删除限时房卡 delRfCard
  >func delRfCard(devName: String, basecode: UInt32, cardId: UInt32, index:UInt8) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>cardId: int类型，房卡卡号
    >>index: int类型，房卡序号，0～99，不需要，传0

  >* return: 
    >>code: int类型，200表示删除成功，300表示删除失败    

## 4. 蓝牙密码锁WSL_Ox，NB密码锁WSL_Dx，蓝牙指纹锁WSL_Fx，NB指纹锁WSL_Cx系列锁指令接口

### 4.1 登录态 login1/login2
  >func login1(devName:String, basecode: UInt32) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码  

   >* return data: 
    >>randomN: int类型，解锁第二步加密参数

  >func login2(devName:String, basecode: UInt32, randomN: UInt32) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码  
    >>randomN: int类型，解锁第一步返回

  >* return: 
    >>code: int类型，200表示登录成功，300表示登录失败
注意：登录态表示一种鉴权行为。同步时钟，管理密码，房卡，指纹，均需要先登录后方可操作。

### 4.2 同步时钟 syncClock
  >func syncClock(devName: String, basecode: UInt32, time: Date) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>time: Date类型，本地时钟，例如中国为UTC+8时间

  >* return: 
    >>code: int类型，200表示同步时钟成功，300表示同步时钟失败  
    >>data: object类型，其中msg表示提示信息   
注意：当密码，刷卡，指纹无法开门，或重启后，需要更新时钟。  

### 4.3 添加限时密码 addPincode
  >func addPincode(devName: String, basecode: UInt32, pincode: UInt32, index:UInt8, startTime: Date, endTime: Date) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>pincode: int类型，6位开锁密码
    >>index: int类型，密码序号，0～99
    >>startTime: Date类型，密码生效时间，取本地时钟，例如中国为UTC+8时间
    >>endTime: Date类型，密码失效时间，取本地时钟，例如中国为UTC+8时间

  >* return: 
    >>code: int类型，200表示添加成功，300表示添加失败    
    >>data: object类型，其中msg表示提示信息   
  注意：密码开锁结果上报，接口名称reportPincodeResult，数据结构如下：
  {
    > index: int类型，表示密码序号
    > time: date类型，表示开锁时间
    > isValid: bool类型，表示密码是否开锁成功
  }   

### 4.4 删除限时密码 delPincode
  >func delPincode(devName: String, basecode: UInt32, pincode: UInt32, index:UInt8) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>pincode: int类型，6位开锁密码，不需要，传0
    >>index: int类型，密码序号，0～99，必须

  >* return: 
    >>code: int类型，200表示删除成功，300表示删除失败  

### 4.5 添加限时房卡 addRfCard
  >func addRfCard(devName: String, basecode: UInt32, cardId: UInt32, index:UInt8, startTime: Date, endTime: Date) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>cardId: int类型，房卡卡号，不需要，传0
    >>index: int类型，房卡序号，0～99，必须
    >>startTime: Date类型，房卡生效时间，取本地时钟，例如中国为UTC+8时间
    >>endTime: Date类型，房卡失效时间，取本地时钟，例如中国为UTC+8时间

  >* return: 
    >>code: int类型，100时，表示进入添卡模式，200表示添加成功，300表示添加失败
    >>data: object类型，其中msg表示提示信息   
注意：指纹锁系列添加房卡，是先发送指令进入添卡模式，再刷卡完成添加。
  >密码开锁结果上报，接口名称reportRfCardResult，数据结构如下：
  {
    > index: int类型，表示房卡序号
    > time: date类型，表示开锁时间
    > isValid: bool类型，表示房卡是否开锁成功，但无效房卡不会回调
  }  

### 4.6 删除限时房卡 delRfCard
  >func delRfCard(devName: String, basecode: UInt32, cardId: UInt32, index:UInt8) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>cardId: int类型，房卡卡号，不需要，传0
    >>index: int类型，房卡序号，0～99，必须

  >* return: 
    >>code: int类型，200表示删除成功，300表示删除失败    

### 4.7 添加限时指纹 addFingerprint
  >func addFingerprint(devName: String, basecode: UInt32, index:UInt8, startTime: Date, endTime: Date) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>index: int类型，指纹序号，0～99，必须
    >>startTime: Date类型，指纹生效时间，取本地时钟，例如中国为UTC+8时间
    >>endTime: Date类型，指纹失效时间，取本地时钟，例如中国为UTC+8时间

  >* return: 
    >>code: int类型，100时，表示进入添加指纹模式，200表示添加成功，300表示添加失败
    >>data: object类型，其中msg表示提示信息   
注意：指纹锁系列添加指纹，是先发送指令进入添加指纹，再刷反复录入指纹完成添加。
  >指纹开锁结果上报，接口名称reportFingerprintResult，数据结构如下：
  {
    > index: int类型，表示指纹序号
    > time: date类型，表示开锁时间
    > isValid: bool类型，表示指纹是否开锁成功，但无效指纹不会回调
  }  

### 4.8 删除限时指纹 delFingerprint
  >func delFingerprint(devName: String, basecode: UInt32, index:UInt8) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>basecode: int类型，蓝牙通信加密码
    >>index: int类型，指纹序号，0～99，必须

  >* return: 
    >>code: int类型，200表示删除成功，300表示删除失败   

### 4.9 修改管理密码 changeAdminPincode
  >func changeAdminPincode(devName: String, mac: String, oldPwd:UInt32, newPwd:UInt32) ->Data
  >* params: 
    >>devName: String类型，锁蓝牙名称
    >>mac: String类型，锁蓝牙MAC地址
    >>oldPwd: int类型，锁原来管理密码，初始状态默认12345678，可开门
    >>newPwd: int类型，锁新的管理密码

  >* return: 
    >>code: int类型，200表示修改成功，300表示修改失败  
注意：指纹锁初始状态下管理密码为12345678，因此绑定门锁后，建议立即修改管理密码。

## 5. Nx,Mx,Cx,Dx NB系列锁指令接口

### 5.1 获取NB模组IMEI queryNbImei
  >func queryNbImei(devName:String) -> Data
  >* params: 
    >>devName: String类型，锁蓝牙名称

  >* return data: 
    >>imei: String类型，表示NB模组设备imei
