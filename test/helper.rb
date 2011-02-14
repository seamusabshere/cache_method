require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
require 'ruby-debug'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'cache_method'

class Test::Unit::TestCase
end

require 'active_support'
require 'active_support/version'
require 'active_support/memoizable' if ActiveSupport::VERSION::MAJOR == 3
class MemoizedRemoteBlog
  extend ActiveSupport::Memoizable
  attr_writer :request_count
  def request_count
    @request_count ||= 0
  end
  def get_latest_entries
    self.request_count += 1
    'hello world'
  end
  memoize :get_latest_entries
end
class CachedRemoteBlog
  attr_writer :request_count
  def to_cache_key
    'my_blog'
  end
  def request_count
    @request_count ||= 0
  end
  def get_latest_entries
    self.request_count += 1
    'hello world'
  end
  cache_method :get_latest_entries
end

# expects a running memcached server at localhost:11211
require 'memcached'
$my_cache = Memcached.new 'localhost:11211'
CacheMethod.config.client = $my_cache
