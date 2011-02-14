require 'helper'

class TestStoresCacheOffsite < Test::Unit::TestCase
  def test_in_contrast_memoizable_stores_onsite
    a = MemoizedRemoteBlog.new
    a.get_latest_entries
    assert_equal 1, a.request_count
    a = MemoizedRemoteBlog.new
    assert_equal nil, a.request_count
  end
  
  def test_cacheable_stores_offsite
    a = CachedRemoteBlog.new
    a.get_latest_entries
    assert_equal 1, a.request_count
    a = CachedRemoteBlog.new
    assert_equal 1, a.request_count
  end
end
