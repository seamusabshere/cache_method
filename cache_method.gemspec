# -*- encoding: utf-8 -*-
require File.expand_path("../lib/cache_method/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "cache_method"
  s.version     = CacheMethod::VERSION
  s.authors     = ["Seamus Abshere"]
  s.email       = ["seamus@abshere.net"]
  s.homepage    = "https://github.com/seamusabshere/cache_method"
  s.summary     = %q{Lets you cache methods (to memcached, redis, etc.) sort of like you can memoize them}
  s.description = %q{Like alias_method, but it's cache_method!}

  s.rubyforge_project = "cache_method"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'cache', '>=0.2.1'

  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'dalli'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'minitest'
  if RUBY_VERSION >= '1.9'
    s.add_development_dependency 'minitest-reporters'
  end
end
