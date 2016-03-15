# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name                  = 'distributed_lock'
  gem.version               = '0.1.0'
  gem.authors               = ['Doug Ericson']
  gem.email                 = ['doug.ericson@bookbub.com']
  gem.summary               = 'Semaphore implemented using Redis.'
  gem.description           = 'Semaphore implemented using Redis.'
  gem.homepage              = 'https://github.com/BookBub/distributed-lock'
  gem.executables           = []
  gem.files                 = `git ls-files`.split("\n")
  gem.test_files            = `git ls-files -- spec/*`.split("\n")
  gem.require_paths         = ['lib']
  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency "redis", "~> 3.2"
  gem.add_development_dependency 'rspec', '~> 2.14', '>= 2.14.1'
end