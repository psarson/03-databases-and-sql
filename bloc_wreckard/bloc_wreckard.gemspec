Gem::Specification.new do |s|
   s.name          = 'bloc_wreckard'
   s.version       = '0.0.0'
   s.date          = '2017-01-17'
   s.summary       = 'Just a different name for the BlocRecord ORM'
   s.description   = 'An ActiveRecord-esque ORM adaptor'
   s.authors       = ['Patrick Sarson']
   s.email         = 'sarsonmedia@gmail.com'
   s.files         = Dir['lib/**/*.rb']
   s.require_paths = ["lib"]
   s.homepage      =
     'http://rubygems.org/gems/bloc_wreckard'
   s.license       = 'MIT'
   s.add_runtime_dependency 'sqlite3', '~> 1.3'
 end
