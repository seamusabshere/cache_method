require 'singleton'
module CacheMethod
  class Config
    include ::Singleton
    attr_accessor :client
  end
end
