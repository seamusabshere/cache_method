require 'cache_method/version'
# See the README.rdoc for more info!
module CacheMethod
  autoload :Config, 'cache_method/config'
  autoload :CachedResult, 'cache_method/cached_result'
  autoload :Epoch, 'cache_method/epoch'

  def self.config #:nodoc:
    Config.instance
  end
  
  def self.klass_name(obj) #:nodoc:
    obj.is_a?(::Class) ? obj.to_s : obj.class.to_s
  end
  
  def self.method_delimiter(obj) #:nodoc:
    obj.is_a?(::Class) ? '.' : '#'
  end
  
  def self.method_signature(obj, method_id) #:nodoc:
    [ klass_name(obj), method_id ].join method_delimiter(obj)
  end
    
  # All Objects, including instances and Classes, get the <tt>#clear_method_cache</tt> method.
  module InstanceMethods
    # Clear the cache for a particular method.
    #
    # Note: Remember to define <tt>#hash</tt> on any object whose instance methods might get cached.
    #
    # Example:
    #     my_blog.clear_method_cache :get_latest_entries
    def clear_method_cache(method_id)
      ::CacheMethod::Epoch.mark_passing :obj => self, :method_id => method_id
    end
  end

  # All Classes (but not instances), get the <tt>.cache_method</tt> method.
  module ClassMethods
    # Cache a method. TTL in seconds, defaults to whatever's in CacheMethod.config.default_ttl
    #
    # Note: Remember to define <tt>#hash</tt> on any object whose instance methods might get cached.
    #
    # Note 2: Check out CacheMethod.config.default_ttl... the default is only 60 seconds.
    #
    # Example:
    #     class Blog
    #       # [...]
    #       def get_latest_entries
    #         sleep 5
    #       end
    #       # [...]
    #       cache_method :get_latest_entries
    #       # if you wanted a different ttl...
    #       # cache_method :get_latest_entries, 800 #seconds
    #     end
    def cache_method(method_id, ttl = nil)
      original_method_id = "_uncached_#{method_id}"
      alias_method original_method_id, method_id
      define_method method_id do |*args|
        ::CacheMethod::CachedResult.fetch :obj => self, :method_id => method_id, :original_method_id => original_method_id, :ttl => ttl, :args => args
      end
    end
  end
end

unless ::Object.method_defined? :cache_method
  ::Object.send :include, ::CacheMethod::InstanceMethods
  ::Object.extend ::CacheMethod::ClassMethods
end
