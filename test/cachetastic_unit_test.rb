require File.join(File.dirname(__FILE__), "test_helper")

class CachetasticUnitTest < Test::Unit::TestCase


  def setup
    Cachetastic::Caches::Base.expire_all
    AlbumCache.expire_all
  end

  def test_class_cannot_be_instaniate
    assert_raise(NoMethodError) { Cachetastic::Caches::Base.new }
  end
  
  def test_get
    assert_nil Cachetastic::Caches::Base.get(:my_articles_test_get)
    res = Cachetastic::Caches::Base.get(:my_articles_test_get) do
      "hello mark"
    end
    assert_equal "hello mark", res
    assert_nil Cachetastic::Caches::Base.get(:my_articles_test_get)
    
    res = Cachetastic::Caches::Base.get(:my_articles_test_get) do
      Cachetastic::Caches::Base.set(:my_articles_test_get, "hello mark")
    end
    assert_equal "hello mark", res
    assert_not_nil Cachetastic::Caches::Base.get(:my_articles_test_get)
    assert_equal "hello mark", Cachetastic::Caches::Base.get(:my_articles_test_get)
  end
  
  def test_set
    assert true
    Cachetastic::Caches::Base.set(:my_articles, [1, 2, 3], 15.minutes.from_now)
    assert_equal [1,2,3], Cachetastic::Caches::Base.get(:my_articles)
  end
  
  def test_delete
    test_set
    Cachetastic::Caches::Base.delete(:my_articles)
    assert_nil Cachetastic::Caches::Base.get(:my_articles)
  end
  
  def test_expire_all
    a = [1,2,3,4,5,6,7,8,9,10]
    Cachetastic::Caches::Base.set(:testing_expire_all, a)
    assert_equal a, Cachetastic::Caches::Base.get(:testing_expire_all)
    Cachetastic::Caches::Base.expire_all
    assert_nil Cachetastic::Caches::Base.get(:testing_expire_all)
  end
  
  def test_album_cache
    assert true
    res = AlbumCache.get(:recent_albums, 5)
    assert_not_nil res
    assert res.is_a?(Array)
    assert_equal 5, res.size
    res.each do |r|
       assert r.is_a?(ArAlbum)
    end
  end
  
  def test_local_memory_auto_expire
    res = FooBarCache.get(:pickles)
    assert_nil res
    FooBarCache.set(:pickles, "are yummy")
    res = FooBarCache.get(:pickles)
    assert_not_nil res
    assert_equal "are yummy", res
    sleep(4)
    res = FooBarCache.get(:pickles)
    assert_nil res
  end
  
  def test_local_memory_delete
    res = FooBarCache.get(:pickles)
    assert_nil res
    FooBarCache.set(:pickles, "are yummy")
    res = FooBarCache.get(:pickles)
    assert_not_nil res
    assert_equal "are yummy", res
    FooBarCache.delete(:pickles)
    res = FooBarCache.get(:pickles)
    assert_nil res
  end

end
