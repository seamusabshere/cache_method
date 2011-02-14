require 'singleton'
module CacheMethod
  class Clearinghouse
    include ::Singleton
    def mediate(*args, &blk)
      ::CacheMethod.client.fetch(*args, &blk)
    end
  end
end
