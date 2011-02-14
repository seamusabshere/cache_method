require 'singleton'
require 'zlib'
module CacheMethod
  class Client
    include ::Singleton
    
    def fetch(*args, &blk)
      k = assemble_key *args
      if raw_client.respond_to? :fetch
        return raw_client.fetch(k, &blk)
      end
      if cached_v = get(k)
        return cached_v
      end
      set k, blk.call
    end
    
    private
    
    def raw_client
      ::CacheMethod.config.client
    end
    
    def flush
      raw_client.send flush_cmd
    end
    
    def get(k)
      raw_client.send get_cmd, k
    rescue
    end
    
    def set(k, v)
      raw_client.send set_cmd, k, v
      v
    rescue
      v
    end
    
    def assemble_key(*args)
      k = args.flatten.map { |i| i.to_cache_key }.join('/')
      k = if k.length < ::CacheMethod.config.max_key_length
        k
      else
        k[0..(::CacheMethod.config.max_key_length - 11)] + ::Zlib.crc32(k).to_s
      end
      k
    end
    
    def flush_cmd
      @flush_cmd ||= %w{ flush clear }.detect { |cmd| raw_client.respond_to? cmd }
    end
    
    def set_cmd
      @set_cmd ||= %w{ set write }.detect { |cmd| raw_client.respond_to? cmd }
    end
    
    def get_cmd
      @get_cmd ||= %w{ get read }.detect { |cmd| raw_client.respond_to? cmd }
    end
  end
end
