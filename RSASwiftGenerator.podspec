#
# Be sure to run `pod lib lint RSASwiftGenerator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RSASwiftGenerator'
  s.version          = '0.1.0'
  s.summary          = "A wrapper for Apple's RSA Generation function written in Swift."
  s.swift_version    = '4.0'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    Generade and manage your RSA keys. A wrapper for Apple's RSA Generation function written in Swift.
                       DESC

  s.homepage         = 'https://github.com/4taras4/RSASwiftGenerator'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tarik' => '4taras4@gmail.com' }
  s.source           = { :git => 'https://github.com/4taras4/RSASwiftGenerator.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '8.0'
  # s.dependency 'CommonCryptoSwift'
  s.requires_arc = true
  s.source_files = 'Sources/**/*.swift'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2', 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/RSASwiftGenerator/Sources/CCommonCrypto' }
  s.preserve_paths = 'Sources/CCommonCrypto/module.modulemap'

 #  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2', 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/Sources/CCommonCrypto',
 #      'SWIFT_VERSION' => '4.0'
 # }
  # s.preserve_paths = 'Sources/CCommonCrypto/module.modulemap'

end
