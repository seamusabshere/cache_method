require 'singleton'
module CacheMethod
  # All cache requests go through a clearinghouse, allowing uncaching.
  class Cache #:nodoc: all
    autoload :Key, 'cache_method/cache/key'
    autoload :Epoch, 'cache_method/cache/epoch'
    
    include ::Singleton
    
    def flush
      bare_client.send %w{ flush flush_all clear flushdb }.detect { |c| bare_client.respond_to? c }
    end
    
    def fetch(obj, method_id, ttl, *args)
      k = Key.new :obj => obj, :method_id => method_id, :args => args
      if cached_v = get(k.to_s)
        return cached_v
      end
      v = yield
      set k.to_s, v, ttl
      v
    end
    
    def delete(obj, method_id)
      Epoch.mark_passing :obj => obj, :method_id => method_id
    end

    def get(k)
      if defined?(::Memcached) and bare_client.is_a?(::Memcached)
        begin; bare_client.get(k); rescue ::Memcached::NotFound; nil; end
      elsif defined?(::Redis) and bare_client.is_a?(::Redis)
        if cached_v = bare_client.get(k)
          ::Marshal.load cached_v
        end
      elsif bare_client.respond_to?(:get)
        bare_client.get k
      elsif bare_client.respond_to?(:read)
        bare_client.read k
      else
        raise "Don't know how to work with #{bare_client.inspect}"
      end
    end
        
    def set(k, v, ttl)
      ttl ||= ::CacheMethod.config.default_ttl
      if defined?(::Redis) and bare_client.is_a?(::Redis)
        bare_client.set k, ::Marshal.dump(v)
      elsif bare_client.respond_to?(:set)
        bare_client.set k, v, ttl
      elsif bare_client.respond_to?(:write)
        if ttl == 0
          bare_client.write k, v # never expire
        else
          bare_client.write k, v, :expires_in => ttl
        end
      else
        raise "Don't know how to work with #{bare_client.inspect}"
      end
    end
    
    def bare_client
      ::CacheMethod.config.client
    end
  end
end
