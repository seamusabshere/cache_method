require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
# require 'ruby-debug'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'cache_method'

class Test::Unit::TestCase
end

class CopyCat1
  attr_reader :name
  def initialize(name)
    @name = name
  end
  attr_writer :echo_count
  def echo_count
    @echo_count ||= 0
  end
  # http://www.ruby-forum.com/topic/98106
  # matz: "In 1.9, values (i.e. result of splat) are always represented by array,
  #        so that we won't confuse array as an value with array as values
  #        representation."
  def echo(*args)
    self.echo_count += 1
    if RUBY_VERSION >= '1.9'
      if args.empty?
        return nil
      elsif args.length == 1
        return args[0]
      else
        return args
      end
    else
      return *args
    end
  end
  def hash
    name.hash
  end
  cache_method :echo
end

class CopyCat2
  class << self
    attr_writer :echo_count
    def echo_count
      @echo_count ||= 0
    end
    def echo(*args)
      self.echo_count += 1
      if RUBY_VERSION >= '1.9'
        if args.empty?
          return nil
        elsif args.length == 1
          return args[0]
        else
          return args
        end
      else
        return *args
      end
    end
    cache_method :echo
  end
end

class Blog1
  attr_reader :name
  attr_reader :url
  def initialize(name, url)
    @name = name
    @url = url
  end
  attr_writer :request_count
  def request_count
    @request_count ||= 0
  end
  def get_latest_entries
    self.request_count += 1
    ["hello from #{name}"]
  end
  cache_method :get_latest_entries
  def get_latest_entries2
    self.request_count += 1
    ["voo vaa #{name}"]
  end
  cache_method :get_latest_entries2, 1 # second
  def hash
    { :name => name, :url => url }.hash
  end
end
def new_instance_of_my_blog
  Blog1.new 'my_blog', 'http://my_blog.example.com'
end
def new_instance_of_another_blog
  Blog1.new 'another_blog', 'http://another_blog.example.com'
end

class Blog2
  class << self
    attr_writer :request_count
    def request_count
      @request_count ||= 0
    end
    def get_latest_entries
      self.request_count += 1
      'danke schoen'
    end
    cache_method :get_latest_entries
  end
end
