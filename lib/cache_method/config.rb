require 'singleton'
module CacheMethod
  class Config
    include ::Singleton
    attr_accessor :client
    attr_writer :max_key_length
    def max_key_length
      @max_key_length ||= 150
    end
  end
end
