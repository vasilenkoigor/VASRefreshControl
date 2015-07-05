Pod::Spec.new do |s|
  s.name         = "VASRefreshControl"
  s.version      = "1.0"
  s.summary      = "Simple pull to refresh control with RACCommand support."
  s.homepage     = "https://github.com/spbvasilenko/VASRefreshControl"
  
  s.screenshots  = "https://habrastorage.org/files/0ef/bcf/e5c/0efbcfe5ce6041c6aa06901e2c08cff0.gif"
  
  s.author             = { "Igor Vasilenko" => "spb.vasilenko@gmail.com" }
  
  s.platform     = :ios, "6.0"
  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"
  
  s.source_files  = "VASRefreshControl/**/*.{h,m}"
  s.resources = "VASRefreshControl/Resources/*.png"
  
  s.requires_arc = true
  s.dependency "ReactiveCocoa"
end
