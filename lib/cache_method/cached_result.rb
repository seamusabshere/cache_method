require 'digest/md5'
module CacheMethod
  class CachedResult #:nodoc: all
    def initialize(obj, method_id, original_method_id, ttl, args)
      @obj = obj
      @method_id = method_id
      @original_method_id = original_method_id
      @ttl = ttl
      @args = args
    end

    attr_reader :obj
    attr_reader :method_id
    attr_reader :original_method_id
    attr_reader :args
    
    # Store things wrapped in an Array so that nil is accepted
    def fetch
      if v = Config.instance.storage.get(cache_key) and v.is_a?(::Array)
        v[0]
      else
        v = obj.send original_method_id, *args
        Config.instance.storage.set cache_key, [v], ttl
        v
      end
    end
    
    def ttl
      @ttl ||= Config.instance.default_ttl
    end
    
    def cache_key
      if obj.is_a?(::Class) or obj.is_a?(::Module)
        [ 'CacheMethod', 'CachedResult', method_signature, current_generation, args_digest ].compact.join ','
      else
        [ 'CacheMethod', 'CachedResult', method_signature, obj_hash, current_generation, args_digest ].compact.join ','
      end
    end
    
    def method_signature
      @method_signature ||= ::CacheMethod.method_signature(obj, method_id)
    end
            
    def obj_hash
      @obj_hash ||= obj.respond_to?(:method_cache_hash) ? obj.method_cache_hash : obj.hash
    end
  
    def args_digest
      @args_digest ||= args.empty? ? 'empty' : ::Digest::MD5.hexdigest(args.join)
    end
        
    def current_generation
      if Config.instance.generational?
        @current_generation ||= Generation.new(obj, method_id).current
      end
    end
  end
end
