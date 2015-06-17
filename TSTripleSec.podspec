Pod::Spec.new do |s|

  s.name         = "TSTripleSec"
  s.version      = "1.0.5"
  s.summary      = "Objective-C library for TripleSec"
  s.homepage     = "https://github.com/gabriel/TSTripleSec"
  s.license      = { :type => "MIT" }
  s.author       = { "Gabriel Handford" => "gabrielh@gmail.com" }
  s.source       = { :git => "https://github.com/gabriel/TSTripleSec.git", :tag => s.version.to_s }
  s.dependency "NAChloride"
  s.dependency "NACrypto"
  s.dependency "MPMessagePack"
  s.dependency "GHODictionary"
  s.source_files = "TSTripleSec/**/*.{c,h,m}"
  s.requires_arc = true

  s.ios.platform = :ios, "7.0"
  s.ios.deployment_target = "7.0"

  s.osx.platform =  :osx, "10.8"
  s.osx.deployment_target = "10.8"

end
