require 'digest/md5'
module CacheMethod
  class Epoch #:nodoc: all
    class << self
      def current(options = {})
        epoch = new options
        epoch.current
      end
      
      def mark_passing(options = {})
        epoch = new options
        epoch.mark_passing
      end
      
      def random_name
        ::Digest::MD5.hexdigest rand.to_s
      end
    end

    def initialize(options = {})
      options.each do |k, v|
        instance_variable_set "@#{k}", v
      end
    end
    
    attr_reader :obj
    attr_reader :method_id
    
    def method_signature
      @method_signature ||= ::CacheMethod.method_signature(obj, method_id)
    end
    
    def obj_hash
      @obj_hash ||= ::CacheMethod.hashcode(obj)
    end
    
    def cache_key
      [ 'CacheMethod', 'Epoch', method_signature, obj_hash ].join ','
    end
    
    def current
      if cached_v = Config.instance.storage.get(cache_key)
        cached_v
      else
        v = Epoch.random_name
        Config.instance.storage.set cache_key, v
        v
      end
    end
    
    def mark_passing
      Config.instance.storage.delete cache_key
    end
  end
end
