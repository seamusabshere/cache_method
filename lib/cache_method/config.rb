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
    # Example:
    #     CacheMethod.config.storage = Memcached.new '127.0.0.1:11211'
    def storage=(storage)
      @storage = storage
    end

    def storage #:nodoc:
      @storage || raise("You need to set CacheMethod.config.storage with a cache storage of your choice")
    end
    
    # TTL for method caches. Defaults to 60 seconds.
    #
    # Example:
    #     CacheMethod.config.default_ttl = 120 # seconds
    def default_ttl=(seconds)
      @default_ttl = seconds
    end
    
    def default_ttl #:nodoc:
      @default_ttl || 60
    end
  end
end
