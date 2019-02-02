# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Quran App' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Quran App
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!


pod "YYText"
pod "DOFavoriteButton"
pod "pop"
pod "Whisper"
pod "DZNEmptyDataSet"

pod "LNPopupController"
pod "LUNTabBarController"
pod "CFAlertViewController"
pod "Bohr"
pod "GDLoadingIndicator", "~> 1.0.0"
pod "BEMCheckBox"
pod "DynamicButton"

pod "TOScrollBar"
pod "Hero"
pod "DynamicColor", "~> 3.2.1"

pod "Alamofire"

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end

end
