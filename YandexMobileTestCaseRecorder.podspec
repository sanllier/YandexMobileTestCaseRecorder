#
#  Be sure to run `pod spec lint YandexMobileTestCaseRecorder.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.homepage     = "https://github.com/sanllier/YandexMobileTestCaseRecorder"
  s.summary      = "Recording & validating test cases utility"

  s.name         = "YandexMobileTestCaseRecorder"
  s.version      = "0.1"
  s.license      = "MIT"
  s.author       = { "Alexander Goremykin" => "sanllier@yandex-team.ru" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/sanllier/YandexMobileTestCaseRecorder.git", :tag => "#{s.version}" }

  s.source_files  = "YandexMobileTestCaseRecorder", "YandexMobileTestCaseRecorder/*.{swift,h,m}"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }

end
