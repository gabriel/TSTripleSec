Pod::Spec.new do |s|

  s.name         = "TripleSec"
  s.version      = "1.0.1"
  s.summary      = "Objective-C library for TripleSec)"
  s.homepage     = "https://github.com/gabriel/TripleSec"
  s.license      = { :type => "MIT" }
  s.author       = { "Gabriel Handford" => "gabrielh@gmail.com" }
  s.source       = { :git => "https://github.com/gabriel/TripleSec.git", :tag => "1.0.1" }
  s.platform     = :ios, '7.0'
  s.dependency 'NAChloride'
  s.source_files = 'TripleSec/**/*.{c,h,m}'
  s.requires_arc = true

end
