module CacheMethod
  class Generation #:nodoc: all
    class << self
      def random_name
        rand(100_000_000).to_s
      end
    end

    def initialize(obj, method_id)
      @obj = obj
      @method_id = method_id
    end
    
    attr_reader :obj
    attr_reader :method_id
    
    def method_signature
      @method_signature ||= ::CacheMethod.method_signature(obj, method_id)
    end
    
    def obj_hash
      @obj_hash ||= obj.respond_to?(:method_cache_hash) ? obj.method_cache_hash : obj.hash
    end
    
    def cache_key
      if obj.is_a? ::Class or obj.is_a? ::Module
        [ 'CacheMethod', 'Generation', method_signature ].join ','
      else
        [ 'CacheMethod', 'Generation', method_signature, obj_hash ].join ','
      end
    end
    
    def current
      if cached_v = Config.instance.storage.get(cache_key)
        cached_v
      else
        v = Generation.random_name
        # never expire!
        Config.instance.storage.set cache_key, v, 0
        v
      end
    end
    
    def mark_passing
      Config.instance.storage.delete cache_key
    end
  end
end
