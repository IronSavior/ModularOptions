Gem::Specification.new do |s|
  s.name        = 'cli-modular_options'
  s.summary     = 'Modular Command-Line Options'
  s.description =
    'Facilitates modular application design by allowing you to declare CLI options in ' \
    'the context of a class or module and consume them in the context of an object ' \
    'instance using conventional ruby inheritance semantics.'
  s.license     = 'MIT'
  s.author      = 'Erik Elmore'
  s.email       = 'erik@erikelmore.com'
  s.homepage    = 'https://github.com/IronSavior/ModularOptions'
  
  s.version     = '0.0.0'
  s.files       = Dir.glob('lib/**/*.rb') + ['LICENSE', 'README.md']
  s.test_files  = Dir.glob('spec/**/*.rb')
  s.add_development_dependency 'rspec', '~> 3'
  s.required_ruby_version = '>= 1.9.3'
end
