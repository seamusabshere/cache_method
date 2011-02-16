require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
# require 'ruby-debug'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'cache_method'

class Test::Unit::TestCase
  def setup
    CacheMethod.cache.flush
  end
end

require 'memcached'
require 'memcache'
require 'redis'
require 'dalli'
require 'active_support/all'
require 'active_support/cache/dalli_store'
def random_cache
  c = if ENV['C']
    ENV['C'].to_i
  else
    rand 6
  end
  case c
  when 0
    $stderr.puts 'using memcached'
    Memcached.new 'localhost:11211'
  when 1
    $stderr.puts 'using memcache-client'
    MemCache.new ['localhost:11211']
  when 2
    $stderr.puts 'using dalli'
    Dalli::Client.new ['localhost:11211']
  when 3
    $stderr.puts 'using dalli_store'
    ActiveSupport::Cache::DalliStore.new ['localhost:11211']
  when 4
    $stderr.puts 'using memcached-rails'
    Memcached::Rails.new 'localhost:11211'
  when 5
    $stderr.puts 'using Redis'
    Redis.new
  end
end

$my_cache = random_cache
CacheMethod.config.client = $my_cache
