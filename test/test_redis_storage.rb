require 'helper'

if ENV['REDIS_URL']
  require 'redis'
  require 'uri'

  class TestRedisStorage < Test::Unit::TestCase
    def setup
      super
      uri = URI.parse(ENV["REDIS_URL"])
      storage = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      storage.flushdb
      CacheMethod.config.storage = storage
    end
    
    include SharedTests
  end
end
