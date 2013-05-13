# cache_method

It's like `alias_method`, but it's `cache_method`!

Lets you cache the results of calling methods given their arguments. Like memoization, but stored in Memcached, Redis, etc. so that the cached results can be shared between processes and hosts.

## Real-world usage

<p><a href="http://brighterplanet.com"><img src="https://s3.amazonaws.com/static.brighterplanet.com/assets/logos/flush-left/inline/green/rasterized/brighter_planet-160-transparent.png" alt="Brighter Planet logo"/></a></p>

We use `cache_method` for [data science at Brighter Planet](http://brighterplanet.com/research) and in production at

* [Brighter Planet's impact estimate web service](http://impact.brighterplanet.com)
* [Brighter Planet's reference data web service](http://data.brighterplanet.com)

## Rationale

* It should be easy to cache instance methods
* It should be easy to cache methods that depend on object state
* It should be easy to uncache a method without clearing the whole cache
* It should be easy to do all that using a default in-process store, memcached, dalli (if you're on heroku), redis, etc. (all supported by this gem through the [cache gem](https://rubygems.org/gems/cache))

## Example

    require 'cache_method'
    class Blog

      attr_reader :name, :url

      def initialize(name, url)
        @name = name
        @url = url
      end

      def entries(date)
        # ...
      end

      # cache that slow method!
      cache_method :entries

      def update(stuff)
        # ...
      end

      # automatically clear cache for #entries when #update is called...
      cache_method_clear_on :update, :entries

      # custom cache key - not always required!
      def as_cache_key
        { :name => name, :url => url }
      end
    end

Then you can do

    my_blog.entries(Date.today) => first time won't be cached
    my_blog.entries(Date.today) => second time will come from cache

And clear them too

    my_blog.cache_method_clear :entries

(which doesn't delete the rest of your cache)

## Configuration (and supported cache clients)

By default, an in-process, non-shared cache is used.

You can set where the cache will be stored:

    CacheMethod.config.storage = Memcached.new '127.0.0.1:11211'

or

    CacheMethod.config.storage = Redis.new

or this might even work...

    CacheMethod.config.storage = Rails.cache

See `Config` for the full list of supported caches.

## Cache keys

Caching a method involves getting cache keys for

1. the object where the method is defined - for example, `my_blog.as_cache_key`
2. the arguments passed to the method - for example, `Marshal.dump(Date.today)`, because `Date#as_cache_key` is not defined

Then the cache keys are SHA-1 hashed and combined for an overall key:

    method signature + obj digest                                                                           + args digest
    Blog#entries     + SHA1(Marshal.dump({:name="Seamus's blog",:url=>"http://numbers.brighterplanet.com"}) + SHA1(Marshal.dump(Date.today))

Technically the full cache key is

    # when caching class methods
    method signature + generation + args digest
    # when caching instance methods
    method signature + obj digest + generation + args digest

(see "Generational caching" below for an explanation of the generation part)

### #as_cache_key

As above, you can define a custom cache key for an object:

    class Blog
      # [...]
      def as_cache_key
        { :name => name, :url => url }
      end
      # [...]
    end

If you don't define `#as_cache_key`, the default is to `Marshal.dump` the whole object. (That's not as terrible as it seems - marshalling is fast!)

### #to_cache_key (danger!)

There's another way to define a cache key, but it should be used with caution because it gives you total control.

The key is to make sure your `#to_cache_key` method identifies both the class and the instance!

### Comparison

<table>
  <tr>
    <th>Method</th>
    <th>Must uniquely identify class</th>
    <th>Must uniquely identify instance</th>
  </tr>
  <tr>
    <td><code>#as_cache_key</code></td>
    <td>N&dagger;</td>
    <td>Y</td>
  </tr>
  <tr>
    <td><code>#to_cache_key</code></td>
    <td>Y</td>
    <td>Y</td>
  </tr>
</table>

&dagger; The class name is automatically inserted for you by calling `object.class.name`, which is what causes all the trouble with `ActiveRecord::Associations::CollectionProxy`, etc.

## ActiveRecord

If you're caching methods on instances of `ActiveRecord::Base`, and/or using them as arguments to other cached methods, then you should probably define something like:

    class ActiveRecord::Base
      def as_cache_key
        attributes
      end
    end

If you find yourself passing association proxies as arguments to cached methods, this might be helpful:

    # For use in ActiveRecord 3.0.x
    class ActiveRecord::Associations::AssociationCollection
      # rare use of to_cache_key
      def to_cache_key
        [
          'ActiveRecord::Associations::AssociationCollection',
          proxy_owner.class.name,
          proxy_owner.id,
          proxy_reflection.name,
          conditions
        ].join('/')
      end
    end

    # For use in ActiveRecord 3.2.x
    class ActiveRecord::Associations::CollectionProxy
      # rare use of to_cache_key
      def to_cache_key
        owner = proxy_association.owner
        [
          'ActiveRecord::Associations::CollectionProxy',   # [included because we're using #to_cache_key instead of #as_cache_key ]
          owner.class.name,                                # User
          owner.id,                                        # 'seamusabshere'
          proxy_association.reflection.name,               # :comments
          scoped.where_sql                                 # "WHERE `comments`.`user_id` = 'seamusabshere'" [maybe a little bit redundant, but play it safe]
        ].join('/')
      end
    end

Otherwise, `cache_method` will call `user.comments.class.name` which causes the proxy to load the target, i.e. load all the Comment objects into memory. You probably don't want to load 1000 AR objects just to generate a cache key.

## Generational caching

Generational caching allows clearing the cached results for only one method, for example

    my_blog.cache_method_clear :entries

You can disable it to get a little speed boost

    CacheMethod.config.generational = false

## Debug

CacheMethod can warn you if your obj or args cache keys are suspiciously long.

    require 'cache_method'
    require 'cache_method/debug'

Then watch your logs.

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

## Contributors

* [Seamus Abshere](https://github.com/seamusabshere)
* [Rubem Nakamura](https://github.com/rubemz)

## Copyright

Copyright 2012 Seamus Abshere
