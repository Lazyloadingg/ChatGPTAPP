# Uncomment the next line to define a global platform for your project
# platform :osx, '12.4'
#platform :ios, '12.4'

target 'ChatGPT' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

pod "Alamofire"
pod 'WCDB.swift'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
#      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '12.4'
      config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES' # 消除警告
    end
  end
end
