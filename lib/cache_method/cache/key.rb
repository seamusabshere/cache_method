require 'digest/md5'
module CacheMethod
  class Cache
    class Key
      class << self
        def digest(*ary)
          ::Digest::MD5.hexdigest ary.flatten.map { |i| i.to_s }.join
        end
        def parse(str)
          method_signature, epoch, obj_hash, args_digest = str.split ','
          new :method_signature => method_signature, :epoch => epoch, :obj_hash => obj_hash, :args_digest => args_digest
        end
        def klass_name(obj)
          obj.is_a?(::Class) ? obj.to_s : obj.class.to_s
        end
        def method_delimiter(obj)
          obj.is_a?(::Class) ? '.' : '#'
        end
        def method_signature(obj, method_id)
          [ klass_name(obj), method_id ].join method_delimiter(obj)
        end
      end
  
      def initialize(options = {})
        options.each do |k, v|
          instance_variable_set "@#{k}", v
        end
      end
  
      attr_reader :obj
      attr_reader :method_id
      attr_reader :args

      def obj_hash
        @obj_hash ||= obj.hash
      end
    
      def args_digest
        @args_digest ||= Key.digest(args)
      end
      
      def method_signature
        @method_signature ||= Key.method_signature(obj, method_id)
      end
      
      def epoch
        @epoch ||= Epoch.current(:obj => obj, :method_id => method_id)
      end
    
      def to_str
         [ method_signature, epoch, obj_hash, args_digest ].join ','
      end
      alias :to_s :to_str
    end
  end
end