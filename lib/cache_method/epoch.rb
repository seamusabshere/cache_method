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
      @obj_hash ||= obj.hash
    end
    
    def cache_key
      [ 'CacheMethod', method_signature, obj_hash ].join ','
    end
    
    def current
      Config.instance.storage.get(cache_key).to_i
    end
    
    def mark_passing
      Config.instance.storage.set cache_key, (current+1), 0
    end
  end
end
