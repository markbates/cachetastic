require File.join(File.dirname(__FILE__), "test_helper")

class Person
  include Cachetastic::Cacheable
  
  attr_accessor :name
  
  def cachetastic_key
    self.name
  end
  
  def always_the_same(x, y)
    cacher("always_the_same") do
      x + y
    end
  end
  
end

class Unknown
  include Cachetastic::Cacheable
end

class CacheableTest < Test::Unit::TestCase
  
  def test_cache_classes_are_auto_genned
    assert !Cachetastic::Cacheable.const_defined?("PersonCache")
    assert Person.cache_class == Cachetastic::Cacheable::PersonCache
    assert Cachetastic::Cacheable.const_defined?("PersonCache")
    assert !Cachetastic::Cacheable.const_defined?("UnknownCache")
    assert Unknown.cache_class == Cachetastic::Cacheable::UnknownCache
    assert Cachetastic::Cacheable.const_defined?("UnknownCache")
  end
  
  def test_no_cachetastic_key
    assert_raise(NoMethodError) { Unknown.new.cachetastic_key }
    assert_raise(NoMethodError) { Unknown.new.cache_self }
    assert_raise(NoMethodError) { Unknown.new.uncache_self }
  end
  
  def test_cache_uncache_self
    p = Person.new
    p.name = "Mark Bates"
    assert_nil Cachetastic::Cacheable::PersonCache.get("Mark Bates")
    p.cache_self
    assert_equal p, Cachetastic::Cacheable::PersonCache.get("Mark Bates")
    p.uncache_self
    assert_nil Cachetastic::Cacheable::PersonCache.get("Mark Bates")
  end
  
  def test_cacher
    p = Person.new
    assert_nil Cachetastic::Cacheable::PersonCache.get("always_the_same")
    assert_equal 4, p.always_the_same(1,3)
    assert_equal 4, Cachetastic::Cacheable::PersonCache.get("always_the_same")
    assert_equal 4, p.always_the_same(99,99)
    assert_equal 4, Person.get_from_cache("always_the_same")
    assert_nil Cachetastic::Cacheable::PersonCache.get("say_hi")
    Person.cacher("say_hi") do
      "hi there"
    end
    assert_equal "hi there", Cachetastic::Cacheable::PersonCache.get("say_hi")
    assert_equal "hi there", Person.get_from_cache("say_hi")
    assert_equal "hi there", Person.cacher("say_hi")
  end
  
  def test_get_from_cache
    assert_nil Person.get_from_cache("i should be nil")
    assert_equal 86, Person.get_from_cache("maxwell smart") {86}
    x = Person.get_from_cache("my name") do |key|
      "Mark Bates"
    end
    assert_equal "Mark Bates", x
  end
  
end