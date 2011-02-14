# require 'active_support'
# require 'active_support/version'
# %w{
#   active_support/core_ext/object
#   active_support/core_ext/class
# }.each do |active_support_3_requirement|
#   require active_support_3_requirement
# end if ActiveSupport::VERSION::MAJOR == 3

module CacheMethod
  autoload :Config, 'cache_method/config'
  autoload :Clearinghouse, 'cache_method/clearinghouse'
  autoload :Client, 'cache_method/client'

  def self.config
    Config.instance
  end
  def self.clearinghouse
    Clearinghouse.instance
  end
  def self.client
    Client.instance
  end

  module InstanceMethods
    def to_cache_key
      to_s
    end    
  end

  module ClassMethods
    def cache_method(method_id)
      original_method_id = :"_uncached_#{method_id}"
      alias_method original_method_id, method_id
      define_method method_id do |*args|
        ::CacheMethod.clearinghouse.mediate to_cache_key, method_id, *args do
          send original_method_id, *args
        end
      end
    end
  end
end

unless ::Object.method_defined? :cache_method
  ::Object.extend ::CacheMethod::ClassMethods
  ::Object.send :include, ::CacheMethod::InstanceMethods
end
