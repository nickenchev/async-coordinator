Pod::Spec.new do |spec|
  spec.name         = 'AsyncCoordinator'
  spec.version      = 'v1.0'
  spec.homepage     = 'https://github.com/nickenchev/async-coordinator'
  spec.authors      = { 'Nick Enchev' => 'nikolaenchev@gmail.com' }
  spec.summary      = 'Manage multiple async requests in a parallel or serial manner.'
  spec.source       = { :git => 'https://github.com/nickenchev/async-coordinator.git', :tag => spec.version }
end
