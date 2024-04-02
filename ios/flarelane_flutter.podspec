#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flarelane_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flarelane_flutter'
  s.version          = '1.6.0'
  s.summary          = 'FlareLane Flutter SDK'
  s.description      = <<-DESC
FlareLane Flutter SDK
                       DESC
  s.homepage         = 'https://flarelane.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FlareLane' => 'help@FlareLane.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.dependency "FlareLane", '1.6.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
