require 'helper'

# the famous memcache-client
require 'memcache'

class TestMemcacheStorage < Test::Unit::TestCase
  def setup
    super
    storage = MemCache.new ['localhost:11211']
    storage.flush_all
    CacheMethod.config.storage = storage
  end
    
  include SharedTests
end
