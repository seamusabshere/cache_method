module CacheMethod
  class CachedResult #:nodoc: all
    def obj_digest
      if (l = ::Marshal.dump(CachedResult.resolve_cache_key(obj)).length) > 500
        $stderr.puts "Warn: #{l} long obj digest. #{obj.class} -> #{CachedResult.resolve_cache_key(obj).inspect}"
      end
      @obj_digest ||= ::Digest::SHA1.hexdigest(::Marshal.dump(CachedResult.resolve_cache_key(obj)))
    end
  
    def args_digest
      if (l = ::Marshal.dump(CachedResult.resolve_cache_key(args)).length) > 500
        $stderr.puts "Warn: #{l} long args digest. #{method_signature}(#{CachedResult.resolve_cache_key(args).inspect})"
      end
      @args_digest ||= args.empty? ? 'empty' : ::Digest::SHA1.hexdigest(::Marshal.dump(CachedResult.resolve_cache_key(args)))
    end
  end
end
