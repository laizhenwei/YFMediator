Pod::Spec.new do |s|
  s.name             = 'YFMediator'
  s.version          = '0.1.0'
  s.summary          = 'iOS Mediator'
  s.description      = <<-DESC
                       YFMediator is a part of YFKit
                       DESC
  s.homepage         = 'https://github.com/laichanwai/YFMediator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'laizw' => 'i@laizw.cn' }
  s.source           = { :git => 'https://github.com/laichanwai/YFMediator.git', :tag => s.version }
  s.ios.deployment_target = '6.0'
  s.source_files = 'YFMediator', 'YFMediator/*.{h,m}'
end
