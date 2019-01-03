source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def rx
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxOptional'
  pod 'Action'
end

target 'HasUnderlyingError' do
  rx
end

target 'HasUnderlyingErrorTests' do
  inherit! :search_paths
  rx
  pod 'Quick'
  pod 'Nimble'
  pod 'RxTest'
end
