Pod::Spec.new do |s|

  s.name         = "TSTripleSec"
  s.version      = "0.1.1"
  s.summary      = "Objective-C library for TripleSec)"
  s.homepage     = "https://github.com/gabriel/TSTripleSec"
  s.license      = { :type => "MIT" }
  s.author       = { "Gabriel Handford" => "gabrielh@gmail.com" }
  s.source       = { :git => "https://github.com/gabriel/TSTripleSec.git", :tag => "0.1.1" }
  s.platform     = :ios, '7.0'
  s.dependency 'NAChloride'
  s.source_files = 'TSTripleSec/**/*.{c,h,m}'
  s.requires_arc = true

end
