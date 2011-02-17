require 'helper'

require 'memcached'

class TestMemcachedRailsStorage < Test::Unit::TestCase
  def setup
    super
    storage = Memcached::Rails.new 'localhost:11211'
    storage.flush
    CacheMethod.config.storage = storage
  end
    
  include SharedTests
end
