# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cache_method/version"

Gem::Specification.new do |s|
  s.name        = "cache_method"
  s.version     = CacheMethod::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Seamus Abshere"]
  s.email       = ["seamus@abshere.net"]
  s.homepage    = "https://github.com/seamusabshere/cache_method"
  s.summary     = %q{Lets you cache methods (to memcached, redis, etc.) sort of like you can memoize them}
  s.description = %q{Like alias_method, but it's cache_method!}

  s.rubyforge_project = "cache_method"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_dependency 'cache', '>=0.2.1'
  # https://github.com/fauna/memcached/pull/50
  s.add_development_dependency 'memcached', '<=1.2.6'
  s.add_development_dependency 'rake'
  # if RUBY_VERSION >= '1.9'
  #   s.add_development_dependency 'ruby-debug19'
  # else
  #   s.add_development_dependency 'ruby-debug'
  # end
end
