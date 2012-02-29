require 'digest/sha1'
module CacheMethod
  class CachedResult #:nodoc: all
    CACHE_KEY_JOINER = ','
    ARG_HASH_JOINER = '/'

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
    
    def ttl
      @ttl ||= Config.instance.default_ttl
    end
    
    def cache_key
      if obj.is_a?(::Class) or obj.is_a?(::Module)
        [ 'CacheMethod', 'CachedResult', method_signature, current_generation, args_digest ].compact.join CACHE_KEY_JOINER
      else
        [ 'CacheMethod', 'CachedResult', method_signature, obj_hash, current_generation, args_digest ].compact.join CACHE_KEY_JOINER
      end
    end
    
    def method_signature
      @method_signature ||= ::CacheMethod.method_signature(obj, method_id)
    end
            
    def obj_hash
      @obj_hash ||= obj.respond_to?(:method_cache_hash) ? obj.method_cache_hash : obj.hash
    end
  
    def args_digest
      @args_digest ||= args.empty? ? 'empty' : calculate_args_digest
    end
        
    def current_generation
      if Config.instance.generational?
        @current_generation ||= Generation.new(obj, method_id).current
      end
    end

    private

    def calculate_args_digest
      # equality ruby 1.8 and 1.9 splat behavior
      # FIXME i don't think cache_method should handle this, really
      hashes = args.map do |arg|
        case arg
        when ::Array
          arg.map { |subarg| subarg.hash }.join(ARG_HASH_JOINER)
        else
          arg.hash
        end
      end
      ::Digest::SHA1.hexdigest hashes.join(ARG_HASH_JOINER)
    end
  end
end
