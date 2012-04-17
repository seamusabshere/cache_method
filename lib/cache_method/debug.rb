module CacheMethod
  def CacheMethod.digest(obj)
    if (l = ::Marshal.dump(resolve_cache_key(obj)).length) > 500
      $stderr.puts "[cache_method] Warn: #{l} long digest. #{obj.class} -> #{resolve_cache_key(obj).inspect}"
    end
    ::Digest::SHA1.hexdigest ::Marshal.dump(resolve_cache_key(obj))
  end
end
