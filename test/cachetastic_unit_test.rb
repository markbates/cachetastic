require File.join(File.dirname(__FILE__), "test_helper")

class CachetasticUnitTest < Test::Unit::TestCase

  # def test_memcache_connections_dont_die
  #   10000.times do |i|
  #     MemcacheBenchmarkCache.set(i, i)
  #     assert_equal i, MemcacheBenchmarkCache.get(i)
  #   end
  # end

  def test_ar_cache
    album = ActivePresenterAlbum.find(1)
    assert !Cachetastic::Caches::ActiveRecord.const_defined?("ActivePresenterAlbumCache")
    album.cache_self
    assert Cachetastic::Caches::ActiveRecord.const_defined?("ActivePresenterAlbumCache")
    assert_equal album, Cachetastic::Caches::ActiveRecord::ActivePresenterAlbumCache.get(1)
    
    song = ActivePresenterSong.find(1)
    assert !Cachetastic::Caches::ActiveRecord.const_defined?("ActivePresenterSongCache")
    song.cache_self
    assert Cachetastic::Caches::ActiveRecord.const_defined?("ActivePresenterSongCache")
    assert_equal song, Cachetastic::Caches::ActiveRecord::ActivePresenterSongCache.get(1)
    assert_equal album, Cachetastic::Caches::ActiveRecord::ActivePresenterAlbumCache.get(1)
    
    song.uncache_self
    assert_nil Cachetastic::Caches::ActiveRecord::ActivePresenterSongCache.get(1)
    
    ac = ActivePresenterAlbum.get_from_cache(1)
    assert_not_nil ac
    assert_equal album, ac
    
    ActivePresenterAlbum.delete_from_cache(1)
    ac = ActivePresenterAlbum.get_from_cache(1)
    assert_nil ac
    
    ac = ActivePresenterAlbum.set_into_cache(1, album)
    assert_not_nil ac
    assert_equal album, ac
    
    ac = ActivePresenterAlbum.cacher(:foobar) do
      ActivePresenterAlbum.find(2)
    end
    
    assert_not_nil ac
    assert_equal ActivePresenterAlbum.find(2), ac
    
    ac = ActivePresenterAlbum.get_from_cache(:foobar)
    assert_not_nil ac
    assert_equal ActivePresenterAlbum.find(2), ac
    
    assert_equal [1,2,3,:yippie], ac.some_numbers([1,2,3])
    assert_equal [1,2,3,:yippie], ActivePresenterAlbum.get_from_cache(:some_numbers)
    assert_equal [1,2,3,:yippie], ac.some_numbers([1,2,3,4,5,6])
    
    ActivePresenterAlbum.delete_from_cache(1)
    ac = ActivePresenterAlbum.get_from_cache(1)
    assert_nil ac
    ac = ActivePresenterAlbum.get_from_cache(1, true)
    assert_not_nil ac
  end

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
       assert r.is_a?(ActivePresenterAlbum)
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
