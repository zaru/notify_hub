# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'NotifyHub' do
    pod 'Alamofire', '~> 3.5'
    pod 'AlamofireImage', '~> 2.5'
    pod 'SwiftyJSON', '~> 2.4'
    pod 'LoginServiceKit', :git => 'https://github.com/Clipy/LoginServiceKit.git', :tag => 'v0.0.1'
end

plugin 'cocoapods-keys', {
  :project => "NotifyHub",
  :keys => [
    "GitHubClientSecret",
    "GitHubClientId"
]}
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end
