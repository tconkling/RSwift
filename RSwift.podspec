Pod::Spec.new do |s|
  s.name = 'RSwift'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'Signals, slots, and reactive values in Swift'
  s.homepage = 'https://github.com/tconkling/RSwift'
  s.social_media_url = 'http://twitter.com/timconkling'
  s.authors = { 'Tim Conkling' => 'tconkling@gmail.com' }
  s.source = { :git => 'https://github.com/tconkling/RSwift.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'RSwift/*.swift'

  s.requires_arc = true
end
