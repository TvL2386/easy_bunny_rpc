# -*- encoding: utf-8 -*-

require File.expand_path('../lib/easy_bunny_rpc/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'easy_bunny_rpc'
  gem.version       = EasyBunnyRPC::VERSION
  gem.summary       = %q{A simple rabbitmq rpc server/client library built on bunny with message serialization using json}
  gem.description   = gem.summary
  gem.license       = 'MIT'
  gem.authors       = ['Tom van Leeuwen']
  gem.email         = 'tom@vleeuwen.eu'
  gem.homepage      = 'https://github.com/TvL2386/easy_bunny_rpc'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'bunny', '~> 1.7'

  gem.add_development_dependency 'bundler', '~> 1.10'
  gem.add_development_dependency 'rake', '~> 10.4'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
end
