# cache_method

It's like `alias_method`, but it's `cache_method`!

Lets you cache the results of calling methods given their arguments. Like memoization, but stored in Memcached, Redis, etc. so that the cached results can be shared between processes and hosts.

## Real-world usage

In production use at [impact.brighterplanet.com](http://impact.brighterplanet.com) and [data.brighterplanet.com](http://data.brighterplanet.com).

## Example

    require 'cache_method'
    class Blog
      attr_reader :name
      attr_reader :url

      def initialize(name, url)
        @name = name
        @url = url
      end

      def get_latest_entries
        # ...
      end
      cache_method :get_latest_entries

      # By default, cache_method derives the cache key for an instance by getting the SHA1 hash of the Marshal.dump
      # If you need to customize how an instance is recognized, you can define #as_cache_key.
      # Marshal.load will be called on the result.
      def as_cache_key
        { :name => name, :url => url }
      end
    end

Then you can do

    my_blog.get_latest_entries => first time won't be cached
    my_blog.get_latest_entries => second time will come from cache

And clear them too

    my_blog.cache_method_clear :get_latest_entries

(which doesn't delete the rest of your cache)

## ActiveRecord

If you're caching methods ActiveRecord objects (aka instances of `ActiveRecord::Base`), then you should probably define something like:

    class ActiveRecord::Base
      def as_cache_key
        attributes
      end
    end

## Debug

CacheMethod can warn you if your obj or args cache keys are suspiciously long.

    require 'cache_method'
    require 'cache_method/debug'

Then watch your logs.

## Configuration (and supported cache clients)

You need to set where the cache will be stored:

    CacheMethod.config.storage = Memcached.new '127.0.0.1:11211'

or

    CacheMethod.config.storage = Redis.new

or this might even work...

    CacheMethod.config.storage = Rails.cache

See `Config` for the full list of supported caches.

## Defining a #as_cache_key method

Since we're not pure functional programmers, sometimes cache hits depend on object state in addition to method arguments. To illustrate:

    my_blog.get_latest_entries

get_latest_entries doesn't take any arguments, so it must depend on my_blog.url or something. This works because we define:

    class Blog
      # [...]
      def as_cache_key
        { :name => name, :url => url }
      end
      # [...]
    end

If you don't define `#as_cache_key`, then `cache_method` will `Marshal.dump` an instance.

## Danger: #to_cache_key

Let's say you want need cache keys from classes that undefine the `#class` method (how annoying). You can define `#to_cache_key`, but **make sure it identifies the class too!** (in addition to the instance.)

For example, if you find yourself passing association proxies as arguments to cached methods, this might be helpful:

    user = User.first
    Foo.bar(user.groups) # you're passing an association as an argument

    class ActiveRecord::Associations::AssociationCollection
      # danger! this is a special case... try to use #as_cache_key instead
      # also note that this example is based on ActiveRecord 3.0.10 ... YMMV
      def to_cache_key
        [ proxy_owner.class.name, proxy_owner.id, proxy_reflection.name, conditions ].join('/')
      end
    end

Otherwise, `cache_method` will try to run `user.groups.class` which causes the proxy to be loaded. You probably don't want to load 1000 AR objects just to generate a cache key.

## Module methods

You can put `#cache_method` right into your module declarations:

    module MyModule
      def my_module_method(args)
        # [...]
      end
      cache_method :my_module_method
    end

    class Tiger
      extend MyModule
    end
    
    class Lion
      extend MyModule
    end
    
Rest assured that `Tiger.my_module_method` and `Lion.my_module_method` will be cached correctly and separately. This, on the other hand, won't work:

    class Tiger
      extend MyModule
      # wrong - will raise NameError Exception: undefined method `my_module_method' for class `Tiger'
      # cache_method :my_module_method
    end

## Rationale

* It should be easy to cache a method using memcached, dalli (if you're on heroku), redis, etc. (that's why I made the [cache gem](https://rubygems.org/gems/cache))
* It should be easy to uncache a method without clearing the whole cache
* It should be easy to cache instance methods
* It should be easy to cache methods that depend on object state (hence `#as_cache_key`)

## Copyright

Copyright 2012 Seamus Abshere
