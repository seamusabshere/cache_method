require 'helper'

require 'dalli'

class TestCacheMethod < Test::Unit::TestCase
  def setup
    Blog2.request_count = 0
    CopyCat2.echo_count = 0
    CopyCat1.say_count = 0
    CopyCat2.say_count = 0
    my_cache = Dalli::Client.new '127.0.0.1:11211'
    my_cache.flush
    CacheMethod.config.storage = my_cache
    CacheMethod.config.generational = true
  end

  def test_cache_instance_method_with_args
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      assert_equal ['hi'], a.echo('hi')
      assert_equal 1, a.echo_count

      assert_equal ['hi'], a.echo('hi')
      assert_equal 1, a.echo_count
    else
      assert_equal 'hi', a.echo('hi')
      assert_equal 1, a.echo_count

      assert_equal 'hi', a.echo('hi')
      assert_equal 1, a.echo_count
    end
  end

  def test_cache_instance_method_with_nil_args
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      assert_equal [], a.echo
      assert_equal 1, a.echo_count

      assert_equal [], a.echo
      assert_equal 1, a.echo_count

      assert_equal [nil], a.echo(nil)
      assert_equal 2, a.echo_count

      assert_equal [nil], a.echo(nil)
      assert_equal 2, a.echo_count
    else
      assert_equal nil, a.echo
      assert_equal 1, a.echo_count

      assert_equal nil, a.echo
      assert_equal 1, a.echo_count

      assert_equal nil, a.echo(nil)
      assert_equal 2, a.echo_count

      assert_equal nil, a.echo(nil)
      assert_equal 2, a.echo_count
    end
  end

  def test_cache_instance_method_with_array_args
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      assert_equal [['hi']], a.echo(['hi'])
      assert_equal 1, a.echo_count

      assert_equal [['hi']], a.echo(['hi'])
      assert_equal 1, a.echo_count

      assert_equal [['bye']], a.echo(['bye'])
      assert_equal 2, a.echo_count

      assert_equal [['bye']], a.echo(['bye'])
      assert_equal 2, a.echo_count

      assert_equal [[]], a.echo([])
      assert_equal 3, a.echo_count

      assert_equal [[]], a.echo([])
      assert_equal 3, a.echo_count
    else
      assert_equal ['hi'], a.echo(['hi'])
      assert_equal 1, a.echo_count

      assert_equal ['hi'], a.echo(['hi'])
      assert_equal 1, a.echo_count

      assert_equal ['bye'], a.echo(['bye'])
      assert_equal 2, a.echo_count

      assert_equal ['bye'], a.echo(['bye'])
      assert_equal 2, a.echo_count

      assert_equal [], a.echo([])
      assert_equal 3, a.echo_count

      assert_equal [], a.echo([])
      assert_equal 3, a.echo_count
    end
  end

  def test_cache_instance_method_with_array_args_splat
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      assert_equal [['hi', 'there']], a.echo(['hi', 'there'])
      assert_equal 1, a.echo_count

      assert_equal ['hi', 'there'], a.echo('hi', 'there')
      assert_equal 2, a.echo_count
    else
      assert_equal ['hi', 'there'], a.echo(['hi', 'there'])
      assert_equal 1, a.echo_count

      assert_equal ['hi', 'there'], a.echo('hi', 'there')
      assert_equal 2, a.echo_count
    end
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

    assert_equal [], CopyCat2.echo([])
    assert_equal 3, CopyCat2.echo_count

    assert_equal [], CopyCat2.echo([])
    assert_equal 3, CopyCat2.echo_count
  end

  def test_cache_class_method_with_array_args_splat
    if RUBY_VERSION >= '1.9'
      assert_equal ['hi', 'there'], CopyCat2.echo(['hi', 'there'])
      assert_equal 1, CopyCat2.echo_count

      assert_equal ['hi', 'there'], CopyCat2.echo('hi', 'there')
      assert_equal 2, CopyCat2.echo_count
    else
      assert_equal ['hi', 'there'], CopyCat2.echo(['hi', 'there'])
      assert_equal 1, CopyCat2.echo_count

      assert_equal ['hi', 'there'], CopyCat2.echo('hi', 'there')
      assert_equal 2, CopyCat2.echo_count
    end
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
    a.cache_method_clear :get_latest_entries
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 2, a.request_count
  end

  def test_clear_correct_instance_method
    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count
    a.cache_method_clear :foobar
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
    xxx.cache_method_clear :get_latest_entries
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
    Blog2.cache_method_clear :get_latest_entries
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 2, Blog2.request_count
  end

  def test_clear_correct_class_method
    assert_equal 0, Blog2.request_count
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count

    Blog2.cache_method_clear :foobar
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 1, Blog2.request_count

    Blog2.cache_method_clear :get_latest_entries
    assert_equal 'danke schoen', Blog2.get_latest_entries
    assert_equal 2, Blog2.request_count
  end

  def test_never_set_storage
    CacheMethod.config.instance_variable_set :@storage, nil
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      assert_equal ['hi'], a.echo('hi')
      assert_equal 1, a.echo_count

      assert_equal ['hi'], a.echo('hi')
      assert_equal 1, a.echo_count
    else
      assert_equal 'hi', a.echo('hi')
      assert_equal 1, a.echo_count

      assert_equal 'hi', a.echo('hi')
      assert_equal 1, a.echo_count
    end
  end

  def test_set_storage_to_nil
    CacheMethod.config.storage = nil
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      assert_equal ['hi'], a.echo('hi')
      assert_equal 1, a.echo_count

      assert_equal ['hi'], a.echo('hi')
      assert_equal 1, a.echo_count
    else
      assert_equal 'hi', a.echo('hi')
      assert_equal 1, a.echo_count

      assert_equal 'hi', a.echo('hi')
      assert_equal 1, a.echo_count
    end
  end

  def test_cache_module_method
    assert_equal 0, BlogM.request_count
    assert_equal 'danke schoen', BlogM.get_latest_entries
    assert_equal 1, BlogM.request_count
    assert_equal 'danke schoen', BlogM.get_latest_entries
    assert_equal 1, BlogM.request_count
  end

  def test_as_cache_key
    assert_raises(RuntimeError, /Used as_cache_key/) do
      a = CopyCat1a.new 'mimo'
      a.echo 'hi'
    end
  end

  def test_to_cache_key
    assert_raises(RuntimeError, /Used to_cache_key/) do
      a = CopyCat1b.new 'mimo'
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

    if RUBY_VERSION >= '1.9'
      assert_equal ['hi'], a.echo('hi')
      assert_equal 1, a.echo_count

      assert_equal ['hi'], a.echo('hi')
      assert_equal 1, a.echo_count
    else
      assert_equal 'hi', a.echo('hi')
      assert_equal 1, a.echo_count

      assert_equal 'hi', a.echo('hi')
      assert_equal 1, a.echo_count
    end
  end

  def test_cant_cache_method_clear_without_generational_caching
    CacheMethod.config.generational = false

    a = new_instance_of_my_blog
    assert_equal ["hello from #{a.name}"], a.get_latest_entries
    assert_equal 1, a.request_count

    assert_raises(::RuntimeError) do
      a.cache_method_clear :get_latest_entries
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

  def test_doesnt_marshal_if_as_cache_key_defined
    hello = DontMarshalMe.new("hello")
    world = DontMarshalMe.new("world")

    a = CopyCat1.new 'mimo'
    ack_count = 0

    [
      hello,
      world,
      [hello],
      [world],
      [[hello]],
      [[world]],
      { hello => world },
      { world => hello },
      [{hello => world}],
      [{world => hello}],
      [[{hello => world}]],
      [[{world => hello}]],
      {hello => [{hello => world}]},
      {world => [{hello => world}]},
    ].each do |nasty|
      ack_count += 1
      5.times do
        a.ack(nasty)
        assert_equal ack_count, a.ack_count

        a.ack(nasty)
        assert_equal ack_count, a.ack_count
      end
    end
  end

  def test_cached_query
    a = CopyCat1.new 'mimo'
    assert !a.cache_method_cached?(:echo, 'hi')
    assert !a.cache_method_cached?(:echo, 'there')
    a.echo('hi')
    assert a.cache_method_cached?(:echo, 'hi')
    assert !a.cache_method_cached?(:echo, 'there')

    assert !BlogM.cache_method_cached?(:get_latest_entries)
    assert !BlogM.cache_method_cached?(:get_latest_entries, 'there')
    BlogM.get_latest_entries
    assert BlogM.cache_method_cached?(:get_latest_entries)
    assert !BlogM.cache_method_cached?(:get_latest_entries, 'there')
  end

  def test_class_name_automatically_appended_to_cache_key
    jek = DrJekyll.new
    hyde = MrHyde.new

    assert_equal jek.as_cache_key, hyde.as_cache_key

    a = CopyCat1.new 'mimo'

    a.ack(jek)
    assert_equal 1, a.ack_count

    a.ack(hyde)
    assert_equal 2, a.ack_count

    a.ack(jek)
    assert_equal 2, a.ack_count

    a.ack(hyde)
    assert_equal 2, a.ack_count
  end
end
