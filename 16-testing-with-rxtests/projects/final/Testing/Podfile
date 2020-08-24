platform :ios, '13.0'

# Hue has some warnings, let's silence them.
inhibit_all_warnings!

target 'Testing' do
  use_frameworks!

  pod 'RxSwift', '5.1.1'
  pod 'RxCocoa', '5.1.1'
  pod 'Hue'

  target 'TestingTests' do
    inherit! :search_paths
    pod 'RxTest'
    pod 'RxBlocking'
  end
end
