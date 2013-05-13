require 'thread'
require 'digest/sha1'

require 'cache_method/config'
require 'cache_method/cached_result'
require 'cache_method/generation'

module CacheMethod
  MUTEX = ::Mutex.new
  CACHE_KEY_JOINER = ','

  def CacheMethod.config #:nodoc:
    @config || MUTEX.synchronize do
      @config ||= Config.new
    end
  end

  def CacheMethod.klass_name(obj) #:nodoc:
    (obj.is_a?(::Class) or obj.is_a?(::Module)) ? obj.to_s : obj.class.to_s
  end

  def CacheMethod.method_delimiter(obj) #:nodoc:
    (obj.is_a?(::Class) or obj.is_a?(::Module)) ? '.' : '#'
  end

  def CacheMethod.method_signature(obj, method_id) #:nodoc:
    [ klass_name(obj), method_id ].join method_delimiter(obj)
  end

  def CacheMethod.resolve_cache_key(obj)
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

  def CacheMethod.digest(obj)
    ::Digest::SHA1.hexdigest ::Marshal.dump(resolve_cache_key(obj))
  end

  # All Objects, including instances and Classes, get the <tt>#cache_method_clear</tt> method.
  module InstanceMethods
    # Clear the cache for a particular method.
    #
    # Note: Remember to define <tt>#as_cache_key</tt> on any object whose instance methods might get cached.
    #
    # Example:
    #     my_blog.cache_method_clear :get_latest_entries
    def cache_method_clear(method_id)
      if ::CacheMethod.config.generational?
        ::CacheMethod::Generation.new(self, method_id).mark_passing
      else
        raise ::RuntimeError, "[cache_method] cache_method_clear called, but you have disabled generational caching. Check your setting for CacheMethod.config.generational"
      end
    end

    def cache_method_cached?(method_id, *args)
      ::CacheMethod::CachedResult.new(self, method_id, nil, nil, args).exist?
    end
  end

  # All Classes (but not instances), get the <tt>.cache_method</tt> method.
  module ClassMethods
    # Cache a method. TTL in seconds, defaults to whatever's in CacheMethod.config.default_ttl
    #
    # Note: Remember to define <tt>#as_cache_key</tt> on any object whose instance methods might get cached.
    #
    # Note 2: Check out CacheMethod.config.default_ttl... the default is 24 hours.
    #
    # Example:
    #     class Blog
    #       def get_latest_entries
    #         # [...]
    #       end
    #       cache_method :get_latest_entries
    #     end
    def cache_method(method_id, ttl = nil)
      original_method_id = "_uncached_#{method_id}"
      alias_method original_method_id, method_id
      define_method method_id do |*args, &blk|
        ::CacheMethod::CachedResult.new(self, method_id, original_method_id, ttl, args, &blk).fetch
      end
    end

    # Clear a cache method once another method is called. Useful in situations where
    # you want to clear a cache whenever another method is callled, commonly
    # an update.
    #
    # Example:
    #     class Blog
    #       def get_latest_entries
    #         # [...]
    #       end
    #       def update_entries
    #         # update happens
    #       end
    #       cache_method_clear_on :update_entries, :get_latest_entries
    #     end
    def cache_method_clear_on(method_id, cache_method_clear_id)
      original_method_id = "_original_#{method_id}"
      alias_method original_method_id, method_id

      define_method method_id do |*args, &blk|
        cache_method_clear cache_method_clear_id
        send(original_method_id, *args, &blk)
      end
    end
  end
end

::Object.send :include, ::CacheMethod::InstanceMethods
::Class.send :include, ::CacheMethod::ClassMethods
::Module.send :include, ::CacheMethod::ClassMethods
