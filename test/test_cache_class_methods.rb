require 'helper'

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

class TestCacheClassMethods < Test::Unit::TestCase
  def setup
    super
    Blog2.request_count = 0
  end
  
  def test_cache_method
    assert_equal 0, Blog2.request_count
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count
  end
  
  def test_clear_method
    assert_equal 0, Blog2.request_count
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count
    Blog2.clear_method_cache :get_latest_entries
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 2, Blog2.request_count
  end
    
  def test_clear_method_doesnt_overstep
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
