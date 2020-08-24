use_frameworks!
source 'https://cdn.cocoapods.org'
inhibit_all_warnings!

abstract_target 'TweetieAbstract' do
    pod 'Alamofire', '4.9.1'

    pod 'RxSwift', '5.1.1'
    pod 'RxCocoa', '5.1.1'
    pod 'RealmSwift', '5.1.0'
    pod 'RxRealm', '3.0.0'
    pod 'Unbox', '4.0.0'
    pod 'Then', '2.7.0'
    pod 'Reachability', '3.2.0'
    pod 'RxRealmDataSources', '0.3.0'

    target 'Tweetie' do
        platform :ios, '12.0'
        pod 'RxDataSources', '4.0.1'
    end
    
    target 'MacTweetie' do
        platform :osx, '10.14'
    end
    
    target 'TweetieTests' do
        platform :ios, '12.0'
        pod 'RxTest', '5.1.1'
        pod 'RxBlocking', '5.1.1'
    end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
