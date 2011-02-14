require 'helper'

class TestInterfaceLikeMemoizable < Test::Unit::TestCase
  def test_memoizable
    a = MemoizedRemoteBlog.new
    assert_equal nil, a.request_count
    a.get_latest_entries
    assert_equal 1, a.request_count
    a.get_latest_entries
    assert_equal 1, a.request_count
  end
  
  def test_cacheable
    a = CachedRemoteBlog.new
    assert_equal nil, a.request_count
    a.get_latest_entries
    assert_equal 1, a.request_count
    a.get_latest_entries
    assert_equal 1, a.request_count
  end
end
