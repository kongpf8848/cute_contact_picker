#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'cute_contact_picker'
  s.version          = '0.1.0'
  s.summary          = '一款获取联系人数据的Flutter插件'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/kongpf8848/cute_contact_picker'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'kongpf8848' => 'kongpf8848@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '12.0'
end

