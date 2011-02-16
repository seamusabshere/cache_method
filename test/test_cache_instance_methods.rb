require 'helper'

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

class TestCacheInstanceMethods < Test::Unit::TestCase
  def new_instance_of_my_blog
    Blog1.new 'my_blog', 'http://my_blog.example.com'
  end
  def new_instance_of_another_blog
    Blog1.new 'another_blog', 'http://another_blog.example.com'
  end
  
  def test_cache_method
    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 0, a.request_count
    xxx = new_instance_of_another_blog
    assert_equal ["hello from #{xxx.name}"], xxx.get_latest_entries
    assert_equal 1, xxx.request_count
  end
  
  def test_clear_method
    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
    a.clear_method_cache :get_latest_entries
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 2, a.request_count
  end
  
  def test_clear_a_different_method
    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
    a.clear_method_cache :foobar
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
  end
    
  def test_clear_from_somebody_else
    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
    xxx = new_instance_of_another_blog
    assert_equal ["hello from #{xxx.name}"], xxx.get_latest_entries
    assert_equal 1, xxx.request_count
    xxx.clear_method_cache :get_latest_entries
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
    assert_equal ["hello from #{xxx.name}"], xxx.get_latest_entries
    assert_equal 2, xxx.request_count
  end
  
  def test_ttl
    a = new_instance_of_my_blog
    assert_equal ["voo vaa #{a.name}"], a.get_latest_entries2
    assert_equal 1, a.request_count
    a = new_instance_of_my_blog
    sleep 2
    assert_equal ["voo vaa #{a.name}"], a.get_latest_entries2
    assert_equal 1, a.request_count
  end
end
