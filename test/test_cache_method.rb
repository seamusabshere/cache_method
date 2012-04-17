require 'helper'

require 'dalli'

describe CacheMethod do
  before do
    Blog2.request_count = 0
    CopyCat2.echo_count = 0
    CopyCat1.say_count = 0
    CopyCat2.say_count = 0
    BlogM.request_count = 0
    my_cache = Dalli::Client.new '127.0.0.1:11211'
    my_cache.flush
    CacheMethod.config.storage = my_cache
    CacheMethod.config.generational = true
  end

  it %{cache_instance_method_with_args} do
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      a.echo('hi').must_equal ['hi']
      a.echo_count.must_equal 1

      a.echo('hi').must_equal ['hi']
      a.echo_count.must_equal 1
    else
      a.echo('hi').must_equal 'hi'
      a.echo_count.must_equal 1

      a.echo('hi').must_equal 'hi'
      a.echo_count.must_equal 1
    end
  end

  it %{cache_instance_method_with_nil_args} do
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      a.echo.must_equal []
      a.echo_count.must_equal 1

      a.echo.must_equal []
      a.echo_count.must_equal 1

      a.echo(nil).must_equal [nil]
      a.echo_count.must_equal 2

      a.echo(nil).must_equal [nil]
      a.echo_count.must_equal 2
    else
      a.echo.must_equal nil
      a.echo_count.must_equal 1

      a.echo.must_equal nil
      a.echo_count.must_equal 1

      a.echo(nil).must_equal nil
      a.echo_count.must_equal 2

      a.echo(nil).must_equal nil
      a.echo_count.must_equal 2
    end
  end

  it %{cache_instance_method_with_array_args} do
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      a.echo(['hi']).must_equal [['hi']]
      a.echo_count.must_equal 1

      a.echo(['hi']).must_equal [['hi']]
      a.echo_count.must_equal 1

      a.echo(['bye']).must_equal [['bye']]
      a.echo_count.must_equal 2

      a.echo(['bye']).must_equal [['bye']]
      a.echo_count.must_equal 2

      a.echo([]).must_equal [[]]
      a.echo_count.must_equal 3

      a.echo([]).must_equal [[]]
      a.echo_count.must_equal 3
    else
      a.echo(['hi']).must_equal ['hi']
      a.echo_count.must_equal 1

      a.echo(['hi']).must_equal ['hi']
      a.echo_count.must_equal 1

      a.echo(['bye']).must_equal ['bye']
      a.echo_count.must_equal 2

      a.echo(['bye']).must_equal ['bye']
      a.echo_count.must_equal 2

      a.echo([]).must_equal []
      a.echo_count.must_equal 3

      a.echo([]).must_equal []
      a.echo_count.must_equal 3
    end
  end

  it %{cache_instance_method_with_array_args_splat} do
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      a.echo(['hi', 'there']).must_equal [['hi', 'there']]
      a.echo_count.must_equal 1

      a.echo('hi', 'there').must_equal ['hi', 'there']
      a.echo_count.must_equal 2
    else
      a.echo(['hi', 'there']).must_equal ['hi', 'there']
      a.echo_count.must_equal 1

      a.echo('hi', 'there').must_equal ['hi', 'there']
      a.echo_count.must_equal 2
    end
  end

  it %{cache_class_method_with_args} do
    CopyCat2.echo('hi').must_equal 'hi'
    CopyCat2.echo_count.must_equal 1

    CopyCat2.echo('hi').must_equal 'hi'
    CopyCat2.echo_count.must_equal 1
  end

  it %{cache_class_method_with_nil_args} do
    CopyCat2.echo.must_equal nil
    CopyCat2.echo_count.must_equal 1

    CopyCat2.echo.must_equal nil
    CopyCat2.echo_count.must_equal 1

    CopyCat2.echo(nil).must_equal nil
    CopyCat2.echo_count.must_equal 2

    CopyCat2.echo(nil).must_equal nil
    CopyCat2.echo_count.must_equal 2
  end

  it %{cache_class_method_with_array_args} do
    CopyCat2.echo(['hi']).must_equal ['hi']
    CopyCat2.echo_count.must_equal 1

    CopyCat2.echo(['hi']).must_equal ['hi']
    CopyCat2.echo_count.must_equal 1

    CopyCat2.echo(['bye']).must_equal ['bye']
    CopyCat2.echo_count.must_equal 2

    CopyCat2.echo(['bye']).must_equal ['bye']
    CopyCat2.echo_count.must_equal 2

    CopyCat2.echo([]).must_equal []
    CopyCat2.echo_count.must_equal 3

    CopyCat2.echo([]).must_equal []
    CopyCat2.echo_count.must_equal 3
  end

  it %{cache_class_method_with_array_args_splat} do
    if RUBY_VERSION >= '1.9'
      CopyCat2.echo(['hi', 'there']).must_equal ['hi', 'there']
      CopyCat2.echo_count.must_equal 1

      CopyCat2.echo('hi', 'there').must_equal ['hi', 'there']
      CopyCat2.echo_count.must_equal 2
    else
      CopyCat2.echo(['hi', 'there']).must_equal ['hi', 'there']
      CopyCat2.echo_count.must_equal 1

      CopyCat2.echo('hi', 'there').must_equal ['hi', 'there']
      CopyCat2.echo_count.must_equal 2
    end
  end

  it %{cache_instance_method} do
    a = new_instance_of_my_blog
    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 1
    a = new_instance_of_my_blog
    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 0
    xxx = new_instance_of_another_blog
    xxx.get_latest_entries.must_equal ["hello from #{xxx.name}"]
    xxx.request_count.must_equal 1
  end

  it %{clear_instance_method} do
    a = new_instance_of_my_blog
    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 1
    a.cache_method_clear :get_latest_entries
    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 2
  end

  it %{clear_correct_instance_method} do
    a = new_instance_of_my_blog
    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 1
    a.cache_method_clear :foobar
    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 1
  end

  it %{clear_instance_method_from_correct_instance} do
    a = new_instance_of_my_blog
    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 1
    xxx = new_instance_of_another_blog
    xxx.get_latest_entries.must_equal ["hello from #{xxx.name}"]
    xxx.request_count.must_equal 1
    xxx.cache_method_clear :get_latest_entries
    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 1
    xxx.get_latest_entries.must_equal ["hello from #{xxx.name}"]
    xxx.request_count.must_equal 2
  end

  it %{cache_instance_method_ttl} do
    a = new_instance_of_my_blog
    a.get_latest_entries2.must_equal ["voo vaa #{a.name}"]
    a.request_count.must_equal 1
    sleep 2
    a.get_latest_entries2.must_equal ["voo vaa #{a.name}"]
    a.request_count.must_equal 2
  end

  it %{cache_class_method} do
    Blog2.request_count.must_equal 0
    Blog2.get_latest_entries.must_equal 'danke schoen'
    Blog2.request_count.must_equal 1
    Blog2.get_latest_entries.must_equal 'danke schoen'
    Blog2.request_count.must_equal 1
  end

  it %{clear_class_method} do
    Blog2.request_count.must_equal 0
    Blog2.get_latest_entries.must_equal 'danke schoen'
    Blog2.request_count.must_equal 1
    Blog2.cache_method_clear :get_latest_entries
    Blog2.get_latest_entries.must_equal 'danke schoen'
    Blog2.request_count.must_equal 2
  end

  it %{clear_correct_class_method} do
    Blog2.request_count.must_equal 0
    Blog2.get_latest_entries.must_equal 'danke schoen'
    Blog2.request_count.must_equal 1

    Blog2.cache_method_clear :foobar
    Blog2.get_latest_entries.must_equal 'danke schoen'
    Blog2.request_count.must_equal 1

    Blog2.cache_method_clear :get_latest_entries
    Blog2.get_latest_entries.must_equal 'danke schoen'
    Blog2.request_count.must_equal 2
  end

  it %{never_set_storage} do
    CacheMethod.config.instance_variable_set :@storage, nil
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      a.echo('hi').must_equal ['hi']
      a.echo_count.must_equal 1

      a.echo('hi').must_equal ['hi']
      a.echo_count.must_equal 1
    else
      a.echo('hi').must_equal 'hi'
      a.echo_count.must_equal 1

      a.echo('hi').must_equal 'hi'
      a.echo_count.must_equal 1
    end
  end

  it %{set_storage_to_nil} do
    CacheMethod.config.storage = nil
    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      a.echo('hi').must_equal ['hi']
      a.echo_count.must_equal 1

      a.echo('hi').must_equal ['hi']
      a.echo_count.must_equal 1
    else
      a.echo('hi').must_equal 'hi'
      a.echo_count.must_equal 1

      a.echo('hi').must_equal 'hi'
      a.echo_count.must_equal 1
    end
  end

  it %{cache_module_method} do
    BlogM.request_count.must_equal 0
    BlogM.get_latest_entries.must_equal 'danke schoen'
    BlogM.request_count.must_equal 1
    BlogM.get_latest_entries.must_equal 'danke schoen'
    BlogM.request_count.must_equal 1
  end

  it %{as_cache_key} do
    lambda do
      a = CopyCat1a.new 'mimo'
      a.echo 'hi'
    end.must_raise(RuntimeError, /Used as_cache_key/)
  end

  it %{to_cache_key} do
    lambda do
      a = CopyCat1b.new 'mimo'
      a.echo 'hi'
    end.must_raise(RuntimeError, /Used to_cache_key/)
  end

  it %{method_added_by_extension} do
    CopyCat2.say('hi').must_equal 'hi'
    CopyCat2.say_count.must_equal 1

    CopyCat2.say('hi').must_equal 'hi'
    CopyCat2.say_count.must_equal 1
  end

  it %{method_added_by_inclusion} do
    a = CopyCat1.new 'sayer'

    a.say('hi').must_equal 'hi'
    a.say_count.must_equal 1

    a.say('hi').must_equal 'hi'
    a.say_count.must_equal 1
  end

  it %{not_confused_by_module} do
    CopyCat2.say('hi').must_equal 'hi'
    CopyCat2.say_count.must_equal 1

    CopyCat2.say('hi').must_equal 'hi'
    CopyCat2.say_count.must_equal 1

    CopyCat1.say('hi').must_equal 'hi'
    CopyCat1.say_count.must_equal 1

    CopyCat1.say('hi').must_equal 'hi'
    CopyCat1.say_count.must_equal 1
  end

  it %{disable_generational_caching} do
    CacheMethod.config.generational = false

    a = CopyCat1.new 'mimo'

    if RUBY_VERSION >= '1.9'
      a.echo('hi').must_equal ['hi']
      a.echo_count.must_equal 1

      a.echo('hi').must_equal ['hi']
      a.echo_count.must_equal 1
    else
      a.echo('hi').must_equal 'hi'
      a.echo_count.must_equal 1

      a.echo('hi').must_equal 'hi'
      a.echo_count.must_equal 1
    end
  end

  it %{cant_cache_method_clear_without_generational_caching} do
    CacheMethod.config.generational = false

    a = new_instance_of_my_blog
    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 1

    assert_raises(::RuntimeError) do
      a.cache_method_clear :get_latest_entries
    end

    a.get_latest_entries.must_equal ["hello from #{a.name}"]
    a.request_count.must_equal 1
  end

  it %{doesnt_rely_on_to_s_for_args_digest} do
    hello = DontStringifyMe.new("hello")
    world = DontStringifyMe.new("world")

    a = CopyCat1.new 'mimo'

    a.echo(hello)
    a.echo_count.must_equal 1

    a.echo(hello)
    a.echo_count.must_equal 1

    a.echo(world)
    a.echo_count.must_equal 2

    a.echo(world)
    a.echo_count.must_equal 2
  end

  it %{doesnt_marshal_if_as_cache_key_defined} do
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
        a.ack_count.must_equal ack_count
        a.ack(nasty)
        a.ack_count.must_equal ack_count
      end
    end
  end

  it %{cached_query} do
    a = CopyCat1.new 'mimo'
    a.cache_method_cached?(:echo, 'hi').must_equal false
    a.cache_method_cached?(:echo, 'there').must_equal false
    a.echo('hi')
    a.cache_method_cached?(:echo, 'hi').must_equal true
    a.cache_method_cached?(:echo, 'there').must_equal false

    BlogM.cache_method_cached?(:get_latest_entries).must_equal false
    BlogM.cache_method_cached?(:get_latest_entries, 'there').must_equal false
    BlogM.get_latest_entries
    BlogM.cache_method_cached?(:get_latest_entries).must_equal true
    BlogM.cache_method_cached?(:get_latest_entries, 'there').must_equal false
  end

  it %{class_name_automatically_appended_to_cache_key} do
    jek = DrJekyll.new
    hyde = MrHyde.new

    hyde.as_cache_key.must_equal jek.as_cache_key

    a = CopyCat1.new 'mimo'

    a.ack(jek)
    a.ack_count.must_equal 1

    a.ack(hyde)
    a.ack_count.must_equal 2

    a.ack(jek)
    a.ack_count.must_equal 2

    a.ack(hyde)
    a.ack_count.must_equal 2
  end
end
