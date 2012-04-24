module CacheMethod
  class CachedResult #:nodoc: all
    def initialize(obj, method_id, original_method_id, ttl, args, &blk)
      @obj = obj
      @method_id = method_id
      @method_signature = CacheMethod.method_signature obj, method_id
      @original_method_id = original_method_id
      @ttl = ttl || CacheMethod.config.default_ttl
      @args = args
      @args_digest = args.empty? ? 'empty' : CacheMethod.digest(args)
      @blk = blk
      @fetch_mutex = ::Mutex.new
    end

    attr_reader :obj
    attr_reader :method_id
    attr_reader :method_signature
    attr_reader :original_method_id
    attr_reader :args
    attr_reader :args_digest
    attr_reader :blk
    attr_reader :ttl
    
    # Store things wrapped in an Array so that nil is accepted
    def fetch
      if wrapped_v = get_wrapped
        wrapped_v.first
      else
        if @fetch_mutex.try_lock
          # i got the lock, so don't bother trying to get first
          begin
            set_wrapped.first
          ensure
            @fetch_mutex.unlock
          end
        else
          # i didn't get the lock, so get in line, and do try to get first
          @fetch_mutex.synchronize do
            (get_wrapped || set_wrapped).first
          end
        end
      end
    end

    def exist?
      CacheMethod.config.storage.exist?(cache_key)
    end
        
    private

    def cache_key
      if obj.is_a?(::Class) or obj.is_a?(::Module)
        [ 'CacheMethod', 'CachedResult', method_signature, current_generation, args_digest ].compact.join CACHE_KEY_JOINER
      else
        [ 'CacheMethod', 'CachedResult', method_signature, CacheMethod.digest(obj), current_generation, args_digest ].compact.join CACHE_KEY_JOINER
      end
    end

    def current_generation
      if CacheMethod.config.generational?
        Generation.new(obj, method_id).fetch
      end
    end

    def get_wrapped
      CacheMethod.config.storage.get cache_key
    end

    def set_wrapped
      v = obj.send(*([original_method_id]+args), &blk)
      wrapped_v = [v]
      CacheMethod.config.storage.set cache_key, wrapped_v, ttl
      wrapped_v
    end
  end
end
