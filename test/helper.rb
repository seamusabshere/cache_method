require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
require 'ruby-debug'
require 'active_support/version'
require 'active_support/memoizable'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'cache_method'

class Test::Unit::TestCase
end

require 'active_support/memoizable' if ActiveSupport::VERSION::MAJOR == 3
class MemoizedRemoteBlog
  extend ActiveSupport::Memoizable
  attr_reader :request_count
  def get_latest_entries
    @request_count ||= 0
    @request_count += 1
    'hello world'
  end
  memoize :get_latest_entries
end
class CachedRemoteBlog
  extend CacheMethod
  attr_reader :request_count
  def get_latest_entries
    @request_count ||= 0
    @request_count += 1
    'hello world'
  end
  cache_method :get_latest_entries
end

# expects a running memcached server at localhost:11211
require 'memcached'
CacheMethod.config.client = Memcached::Rails.new 'localhost:11211'
