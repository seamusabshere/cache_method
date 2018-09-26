require 'cache'

module CacheMethod
  # Here's where you set config options.
  #
  # Example:
  #     CacheMethod.config.storage = Memcached.new '127.0.0.1:11211'
  #     CacheMethod.config.default_ttl = 120 # seconds
  #
  # You'd probably put this in your Rails config/initializers, for example.
  class Config
    attr_reader :storages

    def initialize
      @mutex = ::Mutex.new
      @storages = StorageMap.new
    end

    # Whether to use "generational" caching. Default is true.
    #
    # Pro: enables clearing/flushing/expiring specific methods
    # Con: requires an extra trip to memcached to get the current "generation"
    #
    # Set to false if you just flush everything and don't need to selectively flush particular methods
    def generational=(boolean)
      @generational = boolean
    end

    def generational? #:nodoc:
      @generational == true or @generational.nil?
    end

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
    def storage=(storage = nil)
      @storages[:default] = storage
    end

    def storage #:nodoc:
      @storages[:default] || @mutex.synchronize do
        @storages[:default] ||= ::Cache.new
      end
    end

    alias_method :storage=, :default_storage=
    alias_method :storage,  :default_storage

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

    # TTL for method generational caches. Defaults to 0 (never).
    #
    # Example:
    #     CacheMethod.config.default_generational_ttl = 120 # seconds
    def default_generational_ttl=(seconds)
      @default_generational_ttl = seconds
    end

    def default_generational_ttl #:nodoc:
      @default_generational_ttl || 0
    end
  end

  class StorageMap < Hash
    # Wraps the process of adding / changing a cache storage
    #
    # Examnple:
    #     CacheMethod.config.storages[:memcached] = Memcached.new '127.0.0.1:11211'
    def []=(name, storage)
      self[name] = ::Cache.wrap storage
    end
  end
end
