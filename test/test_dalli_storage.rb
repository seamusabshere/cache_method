require 'helper'

require 'dalli'

class TestDalliStorage < Test::Unit::TestCase
  def setup
    super
    storage = Dalli::Client.new ['localhost:11211']
    storage.flush
    CacheMethod.config.storage = storage
  end
    
  include SharedTests
end
