# Uncomment this line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

inhibit_all_warnings!

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
