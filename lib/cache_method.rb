require 'cache_method/config'
require 'cache_method/cached_result'
require 'cache_method/generation'

# See the README.rdoc for more info!
module CacheMethod
  def self.config #:nodoc:
    Config.instance
  end
  
  def self.klass_name(obj) #:nodoc:
    (obj.is_a?(::Class) or obj.is_a?(::Module)) ? obj.to_s : obj.class.to_s
  end
  
  def self.method_delimiter(obj) #:nodoc:
    (obj.is_a?(::Class) or obj.is_a?(::Module)) ? '.' : '#'
  end
  
  def self.method_signature(obj, method_id) #:nodoc:
    [ klass_name(obj), method_id ].join method_delimiter(obj)
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
      define_method method_id do |*args|
        ::CacheMethod::CachedResult.new(self, method_id, original_method_id, ttl, args).fetch
      end
    end
  end
end

unless ::Object.method_defined? :cache_method
  ::Object.send :include, ::CacheMethod::InstanceMethods
  ::Class.send :include, ::CacheMethod::ClassMethods
  ::Module.send :include, ::CacheMethod::ClassMethods
end
