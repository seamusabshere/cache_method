require 'digest/sha1'
module CacheMethod
  class CachedResult #:nodoc: all
    class << self
      def resolve_cache_key(obj)
        case obj
        when ::Array
          obj.map do |v|
            resolve_cache_key v
          end
        when ::Hash
          obj.inject({}) do |memo, (k, v)|
            kk = resolve_cache_key k
            vv = resolve_cache_key v
            memo[kk] = vv
            memo
          end
        else
          if obj.respond_to?(:to_cache_key)
            # this is meant to be used sparingly, usually when a proxy class is involved
            obj.to_cache_key
          elsif obj.respond_to?(:as_cache_key)
            [obj.class.name, obj.as_cache_key]
          else
            obj
          end
        end
      end
    end
    
    CACHE_KEY_JOINER = ','

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
        v.first
      else
        v = obj.send original_method_id, *args
        Config.instance.storage.set cache_key, [v], ttl
        v
      end
    end

    def exist?
      Config.instance.storage.exist?(cache_key)
    end
    
    def ttl
      @ttl ||= Config.instance.default_ttl
    end
    
    def cache_key
      if obj.is_a?(::Class) or obj.is_a?(::Module)
        [ 'CacheMethod', 'CachedResult', method_signature, current_generation, args_digest ].compact.join CACHE_KEY_JOINER
      else
        [ 'CacheMethod', 'CachedResult', method_signature, obj_digest, current_generation, args_digest ].compact.join CACHE_KEY_JOINER
      end
    end
    
    def method_signature
      @method_signature ||= ::CacheMethod.method_signature(obj, method_id)
    end
            
    def obj_digest
      @obj_digest ||= ::Digest::SHA1.hexdigest(::Marshal.dump(CachedResult.resolve_cache_key(obj)))
    end
  
    def args_digest
      @args_digest ||= args.empty? ? 'empty' : ::Digest::SHA1.hexdigest(::Marshal.dump(CachedResult.resolve_cache_key(args)))
    end
        
    def current_generation
      if Config.instance.generational?
        @current_generation ||= Generation.new(obj, method_id).current
      end
    end
  end
end
