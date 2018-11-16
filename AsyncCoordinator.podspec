Pod::Spec.new do |spec|
  spec.name         = 'AsyncCoordinator'
  spec.version      = '1.2'
  spec.license      = 'BSD'
  spec.homepage     = 'https://github.com/nickenchev/async-coordinator'
  spec.authors      = { 'Nick Enchev' => 'nikolaenchev@gmail.com' }
  spec.summary      = 'Manage multiple async requests in a parallel or serial manner.'
  spec.source       = { :git => 'https://github.com/nickenchev/async-coordinator.git', :tag => spec.version }
  spec.ios.deployment_target = '8.0'

  spec.public_header_files = 'AsyncCoordinator/*.h'
  spec.source_files = 'AsyncCoordinator/*.{h,m}'
end
