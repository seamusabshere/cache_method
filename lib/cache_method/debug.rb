module CacheMethod
  def CacheMethod.digest(obj)
    cache_key = resolve_cache_key obj
    m = Marshal.dump cache_key
    if m.length > 1000
      $stderr.puts
      $stderr.puts "[cache_method] DIGEST (#{'X' * (m.length / 1024)}): #{cache_key.inspect}"
    end
    ::Digest::SHA1.hexdigest m
  end

  class CachedResult
    def args_string
      if kwargs.empty?
        args.inspect
      else
        "#{args.inspect}, #{kwargs.inspect}"
      end
    end

    def debug_get_wrapped
      retval = original_get_wrapped
      if retval
        # $stderr.puts
        # $stderr.puts "[cache_method] GET: #{method_signature}(#{args_string})"
      else
        cache_key = CacheMethod.resolve_cache_key obj
        m = Marshal.dump cache_key
        $stderr.puts
        $stderr.puts "[cache_method] GET (miss!): #{method_signature}(#{args_string}) - #{::Digest::SHA1.hexdigest(m)} - #{cache_key.inspect}"
      end
      retval
    end
    alias :original_get_wrapped :get_wrapped
    alias :get_wrapped :debug_get_wrapped

    def debug_set_wrapped
      retval = original_set_wrapped
      m = Marshal.dump retval
      if m.length > 1000
        $stderr.puts
        $stderr.puts "[cache_method] SET (#{'X' * (m.length / 1024)}): #{method_signature}(#{args_string}) -> #{retval.inspect}"
      else
        # $stderr.puts
        # $stderr.puts "[cache_method] SET: #{method_signature}(#{args_string})"
      end
      retval
    end
    alias :original_set_wrapped :set_wrapped
    alias :set_wrapped :debug_set_wrapped
  end
end
