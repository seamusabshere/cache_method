require 'cache'
require 'singleton'
module CacheMethod
  # Here's where you set config options.
  #
  # Example:
  #     CacheMethod.config.storage = Memcached.new '127.0.0.1:11211'
  #     CacheMethod.config.default_ttl = 120 # seconds
  #
  # You'd probably put this in your Rails config/initializers, for example.
  class Config
    include ::Singleton
    
    # Storage for the cache.
    #
    # Supported memcached clients:
    # * memcached[https://github.com/fauna/memcached] (either a Memcached or a Memcached::Rails)
    # * dalli[https://github.com/mperham/dalli] (either a Dalli::Client or an ActiveSupport::Cache::DalliStore)
    # * memcache-client[https://github.com/mperham/memcache-client] (MemCache, the one commonly used by Rails)
    #
    # Supported Redis clients:
    # * redis[https://github.com/ezmobius/redis-rb]
    #
    # Uses the cache[https://github.com/seamusabshere/cache] gem to wrap these, so support depends on that gem
    #
    # Example:
    #     CacheMethod.config.storage = Memcached.new '127.0.0.1:11211'
    def storage=(raw_client_or_nil)
      if raw_client_or_nil.is_a?(::Cache)
        @storage = raw_client_or_nil
      else
        @storage = ::Cache.new raw_client_or_nil
      end
    end

    def storage #:nodoc:
      @storage ||= ::Cache.new
    end
    
    # TTL for method caches. Defaults to 24 hours or 86,400 seconds.
    #
    # Example:
    #     CacheMethod.config.default_ttl = 120 # seconds
    def default_ttl=(seconds)
      @default_ttl = seconds
    end
    
    def default_ttl #:nodoc:
      @default_ttl || 86_400
    end
  end
end
