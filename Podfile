use_frameworks!

target 'Textor' do
	pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
	pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
  pod 'Socket.IO-Client-Swift', '~> 10.0.0' # Or latest version
  pod 'ReachabilitySwift', '~> 3'
	pod 'Chatto', :git => 'https://github.com/badoo/Chatto', :branch => 'master'
	pod 'ChattoAdditions', :git => 'https://github.com/badoo/Chatto', :branch => 'master'
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'GoogleSignIn'
  pod 'FacebookLogin'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.1'
    end
  end
end
