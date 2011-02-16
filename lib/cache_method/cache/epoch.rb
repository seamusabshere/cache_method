module CacheMethod
  class Cache
    class Epoch
      class << self
        def mark_passing(options = {})
          e = new options
          e.mark_passing
        end
        def current(options = {})
          e = new options
          e.current
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
        @method_signature ||= Key.method_signature(obj, method_id)
      end
      
      def obj_hash
        @obj_hash ||= obj.hash
      end
      
      def cache_key
        [ 'CacheMethod', method_signature, obj_hash ].join ','
      end
      
      def current
        Cache.instance.get(cache_key).to_i
      end
      
      def mark_passing
        Cache.instance.set cache_key, (current+1), 0
      end
    end
  end
end
