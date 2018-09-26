module CacheMethod
  class Generation #:nodoc: all
    def initialize(obj, method_id, storage)
      @obj = obj
      @method_id = method_id
      @storage = storage
      @method_signature = CacheMethod.method_signature obj, method_id
      @fetch_mutex = ::Mutex.new
    end

    attr_reader :obj
    attr_reader :method_id
    attr_reader :storage
    attr_reader :method_signature

    def fetch
      if existing = get
        existing
      else
        @fetch_mutex.synchronize do
          get || set
        end
      end
    end

    def mark_passing
      @storage.delete cache_key
    end

    private

    def cache_key
      if obj.is_a?(::Class) or obj.is_a?(::Module)
        [ 'CacheMethod', 'Generation', method_signature ].join CACHE_KEY_JOINER
      else
        [ 'CacheMethod', 'Generation', method_signature, CacheMethod.digest(obj) ].join CACHE_KEY_JOINER
      end
    end

    def get
      @storage.get cache_key
    end

    def set
      random_name = ::Kernel.rand(1e11).to_s
      @storage.set cache_key, random_name, CacheMethod.config.default_generational_ttl
      random_name
    end
  end
end
