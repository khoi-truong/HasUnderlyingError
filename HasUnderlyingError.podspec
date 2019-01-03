#
# Be sure to run `pod lib lint HasUnderlyingError.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HasUnderlyingError'
  s.version          = '0.1.0'
  s.summary          = 'Simple protocol to better deal with nesting errors.'
  s.description      = <<-DESC
Simple protocol to better deal with nesting errors.
                       DESC
  s.homepage         = 'https://github.com/khoitruongminh/HasUnderlyingError'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'khoitruongminh' => 'khoi.truongminh@gmail.com' }
  s.source           = { :git => 'https://github.com/khoitruongminh/HasUnderlyingError.git', :tag => s.version.to_s }

  s.swift_version    = '4.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'HasUnderlyingError/Source/**/*'
  
  s.frameworks  = "Foundation"
  s.dependency "RxSwift"
  s.dependency "RxCocoa"
  s.dependency "RxOptional"
  s.dependency "Action"
end
