require 'digest/md5'
module CacheMethod
  class CachedResult #:nodoc: all
    class << self
      def fetch(options = {})
        cached_result = new options
        cached_result.fetch
      end
    end
    
    def initialize(options = {})
      options.each do |k, v|
        instance_variable_set "@#{k}", v
      end
    end

    attr_reader :obj
    attr_reader :method_id
    attr_reader :original_method_id
    attr_reader :args
    
    def fetch
      if v = Config.instance.storage.get(cache_key) and v.is_a?(::Array)
        v[0]
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
      [ method_signature, current_epoch, obj_hash, args_digest ].join ','
    end
    
    def method_signature
      @method_signature ||= ::CacheMethod.method_signature(obj, method_id)
    end
            
    def obj_hash
      @obj_hash ||= obj.hash
    end
  
    def args_digest
      @args_digest ||= ::Digest::MD5.hexdigest(args.flatten.join)
    end
        
    def current_epoch
      @current_epoch ||= Epoch.current(:obj => obj, :method_id => method_id)
    end
  end
end
