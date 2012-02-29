require 'helper'

require 'memcached'

class TestCacheMethod < Test::Unit::TestCase
  def setup
    Blog2.request_count = 0
    CopyCat2.echo_count = 0
    CopyCat1.say_count = 0
    CopyCat2.say_count = 0
    my_cache = Memcached.new '127.0.0.1:11211', :binary => true
    my_cache.flush
    CacheMethod.config.storage = my_cache
    CacheMethod.config.generational = true
  end
  
  def test_cache_instance_method_with_args
    a = CopyCat1.new 'mimo'
    
    assert_equal 'hi', a.echo('hi')
    assert_equal 1, a.echo_count
    
    assert_equal 'hi', a.echo('hi')
    assert_equal 1, a.echo_count
  end
  
  def test_cache_instance_method_with_nil_args
    a = CopyCat1.new 'mimo'
    assert_equal nil, a.echo
    assert_equal 1, a.echo_count
    
    assert_equal nil, a.echo
    assert_equal 1, a.echo_count
    
    assert_equal nil, a.echo(nil)
    assert_equal 2, a.echo_count
  
    assert_equal nil, a.echo(nil)
    assert_equal 2, a.echo_count    
  end
  
  def test_cache_instance_method_with_array_args
    a = CopyCat1.new 'mimo'
    
    assert_equal ['hi'], a.echo(['hi'])
    assert_equal 1, a.echo_count
    
    assert_equal ['hi'], a.echo(['hi'])
    assert_equal 1, a.echo_count
    
    assert_equal ['bye'], a.echo(['bye'])
    assert_equal 2, a.echo_count
    
    assert_equal ['bye'], a.echo(['bye'])
    assert_equal 2, a.echo_count
    
    assert_equal ['hi', 'there'], a.echo(['hi', 'there'])
    assert_equal 3, a.echo_count
    
    # same as previous
    assert_equal ['hi', 'there'], a.echo('hi', 'there')
    assert_equal 3, a.echo_count
    
    assert_equal [], a.echo([])
    assert_equal 4, a.echo_count
    
    assert_equal [], a.echo([])
    assert_equal 4, a.echo_count
  end
  
  def test_cache_class_method_with_args
    assert_equal 'hi', CopyCat2.echo('hi')
    assert_equal 1, CopyCat2.echo_count
    
    assert_equal 'hi', CopyCat2.echo('hi')
    assert_equal 1, CopyCat2.echo_count
  end
  
  def test_cache_class_method_with_nil_args
    assert_equal nil, CopyCat2.echo
    assert_equal 1, CopyCat2.echo_count
    
    assert_equal nil, CopyCat2.echo
    assert_equal 1, CopyCat2.echo_count
    
    assert_equal nil, CopyCat2.echo(nil)
    assert_equal 2, CopyCat2.echo_count
  
    assert_equal nil, CopyCat2.echo(nil)
    assert_equal 2, CopyCat2.echo_count    
  end
  
  def test_cache_class_method_with_array_args
    assert_equal ['hi'], CopyCat2.echo(['hi'])
    assert_equal 1, CopyCat2.echo_count
    
    assert_equal ['hi'], CopyCat2.echo(['hi'])
    assert_equal 1, CopyCat2.echo_count
    
    assert_equal ['bye'], CopyCat2.echo(['bye'])
    assert_equal 2, CopyCat2.echo_count
    
    assert_equal ['bye'], CopyCat2.echo(['bye'])
    assert_equal 2, CopyCat2.echo_count
    
    assert_equal ['hi', 'there'], CopyCat2.echo(['hi', 'there'])
    assert_equal 3, CopyCat2.echo_count
    
    assert_equal ['hi', 'there'], CopyCat2.echo('hi', 'there')
    assert_equal 3, CopyCat2.echo_count
    
    assert_equal [], CopyCat2.echo([])
    assert_equal 4, CopyCat2.echo_count
    
    assert_equal [], CopyCat2.echo([])
    assert_equal 4, CopyCat2.echo_count
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
  
  def test_never_set_storage
    CacheMethod.config.instance_variable_set :@storage, nil
    a = CopyCat1.new 'mimo'
    
    assert_equal 'hi', a.echo('hi')
    assert_equal 1, a.echo_count
    
    assert_equal 'hi', a.echo('hi')
    assert_equal 1, a.echo_count
  end
  
  def test_set_storage_to_nil
    CacheMethod.config.storage = nil
    a = CopyCat1.new 'mimo'
    
    assert_equal 'hi', a.echo('hi')
    assert_equal 1, a.echo_count
    
    assert_equal 'hi', a.echo('hi')
    assert_equal 1, a.echo_count
  end
  
  def test_cache_module_method
    assert_equal 0, BlogM.request_count
    assert_equal 'danke schoen', BlogM.get_latest_entries
    assert_equal 1, BlogM.request_count
    assert_equal 'danke schoen', BlogM.get_latest_entries
    assert_equal 1, BlogM.request_count
  end
  
  def test_method_cache_hash
    assert_raises(RuntimeError, /Used method_cache_hash/) do
      a = CopyCat1a.new 'mimo'
      a.echo 'hi'
    end
  end
  
  def test_method_added_by_extension
    assert_equal 'hi', CopyCat2.say('hi')
    assert_equal 1, CopyCat2.say_count

    assert_equal 'hi', CopyCat2.say('hi')
    assert_equal 1, CopyCat2.say_count
  end
  
  def test_method_added_by_inclusion
    a = CopyCat1.new 'sayer'

    assert_equal 'hi', a.say('hi')
    assert_equal 1, a.say_count
    
    assert_equal 'hi', a.say('hi')
    assert_equal 1, a.say_count
  end
  
  def test_not_confused_by_module
    assert_equal 'hi', CopyCat2.say('hi')
    assert_equal 1, CopyCat2.say_count

    assert_equal 'hi', CopyCat2.say('hi')
    assert_equal 1, CopyCat2.say_count

    assert_equal 'hi', CopyCat1.say('hi')
    assert_equal 1, CopyCat1.say_count

    assert_equal 'hi', CopyCat1.say('hi')
    assert_equal 1, CopyCat1.say_count
  end
  
  def test_disable_generational_caching
    CacheMethod.config.generational = false
    
    a = CopyCat1.new 'mimo'
    
    assert_equal 'hi', a.echo('hi')
    assert_equal 1, a.echo_count
    
    assert_equal 'hi', a.echo('hi')
    assert_equal 1, a.echo_count
  end
  
  def test_cant_clear_method_cache_without_generational_caching
    CacheMethod.config.generational = false

    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
    
    assert_raises(::RuntimeError) do
      a.clear_method_cache :get_latest_entries
    end
    
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
  end

  def test_doesnt_rely_on_to_s_for_args_digest
    hello = DontStringifyMe.new("hello")
    world = DontStringifyMe.new("world")

    a = CopyCat1.new 'mimo'
    
    a.echo(hello)
    assert_equal 1, a.echo_count
    
    a.echo(hello)
    assert_equal 1, a.echo_count

    a.echo(world)
    assert_equal 2, a.echo_count

    a.echo(world)
    assert_equal 2, a.echo_count
  end
end
