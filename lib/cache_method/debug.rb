module CacheMethod
  def CacheMethod.digest(obj)
    if (l = ::Marshal.dump(resolve_cache_key(obj)).length) > 500
      $stderr.puts "[cache_method] DIGEST (l = #{l}): #{resolve_cache_key(obj).inspect}"
    end
    ::Digest::SHA1.hexdigest ::Marshal.dump(resolve_cache_key(obj))
  end

  class CachedResult
    def debug_get_wrapped
      retval = original_get_wrapped
      if retval
        # $stderr.puts "[cache_method] GET: #{method_signature}(#{args.inspect})"
      else
        $stderr.puts "[cache_method] GET (miss!): #{method_signature}(#{args.inspect})"
      end
      retval
    end
    alias :original_get_wrapped :get_wrapped
    alias :get_wrapped :debug_get_wrapped

    def debug_set_wrapped
      retval = original_set_wrapped
      if (l = ::Marshal.dump(retval).length) > 1000
        $stderr.puts "[cache_method] SET (l = #{l}): #{method_signature}(#{args.inspect}) -> #{retval.inspect}"
      else
        # $stderr.puts "[cache_method] SET: #{method_signature}(#{args.inspect})"
      end
      retval
    end
    alias :original_set_wrapped :set_wrapped
    alias :set_wrapped :debug_set_wrapped
  end
end
