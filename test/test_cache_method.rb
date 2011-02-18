require 'helper'

require 'memcached'

class TestCacheMethod < Test::Unit::TestCase
  def setup
    Blog2.request_count = 0
    my_cache = Memcached.new '127.0.0.1:11211'
    CacheMethod.config.storage = my_cache
    my_cache.flush
  end
  
  def test_cache_instance_method
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
  
  def test_clear_instance_method
    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
    a.clear_method_cache :get_latest_entries
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 2, a.request_count
  end
  
  def test_clear_correct_instance_method
    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
    a.clear_method_cache :foobar
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
  end
    
  def test_clear_instance_method_from_correct_instance
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
  
  def test_cache_instance_method_ttl
    a = new_instance_of_my_blog
    assert_equal ["voo vaa #{a.name}"], a.get_latest_entries2
    assert_equal 1, a.request_count
    sleep 2
    assert_equal ["voo vaa #{a.name}"], a.get_latest_entries2
    assert_equal 2, a.request_count
  end
  
  def test_cache_class_method
    assert_equal 0, Blog2.request_count
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count
  end
  
  def test_clear_class_method
    assert_equal 0, Blog2.request_count
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count
    Blog2.clear_method_cache :get_latest_entries
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 2, Blog2.request_count
  end
    
  def test_clear_correct_class_method
    assert_equal 0, Blog2.request_count
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count
    
    Blog2.clear_method_cache :foobar
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count
    
    Blog2.clear_method_cache :get_latest_entries
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 2, Blog2.request_count
  end
end
