require 'helper'

require 'dalli'
require 'active_support/all'
require 'active_support/cache/dalli_store'

class TestDalliStoreStorage < Test::Unit::TestCase
  def setup
    super
    storage = ActiveSupport::Cache::DalliStore.new ['localhost:11211']
    storage.clear
    CacheMethod.config.storage = storage
  end
    
  include SharedTests
end
