require 'helper'

require 'memcached'

class TestMemcachedStorage < Test::Unit::TestCase
  def setup
    super
    storage = Memcached.new 'localhost:11211'
    storage.flush
    CacheMethod.config.storage = storage
  end
    
  include SharedTests
end
