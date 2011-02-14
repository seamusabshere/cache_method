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
  
  def self.config
    Config.instance
  end
  
  def cache_method(method_id)
    
  end
end
