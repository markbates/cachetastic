require File.join(File.dirname(__FILE__), "test_helper")

class ActiveRecordTest < Test::Unit::TestCase
  
  def setup
    ArAlbumCache.expire_all
    Cachetastic::Caches::Base.expire_all
    #FileUtils.rm_f(AR_DB, :verbose => true)# if File.exists?(AR_DB)
    begin
      ArMigration.down
    rescue Exception => e
    end
    ArMigration.up
    a = ArAlbum.create(:title => "Abbey Road", :artist => "The Beatles")
    ArSong.create(:title => "Come Together", :album_id => a.id)
    ArSong.create(:title => "Something", :album_id => a.id)
    a = ArAlbum.create(:title => "Help!", :artist => "The Beatles")
    ArSong.create(:title => "Yesterday", :album_id => a.id)
    ArSong.create(:title => "Dizzy Miss Lizzie", :album_id => a.id)
  end
  
  def teardown
    ArMigration.down
    #FileUtils.rm_f(AR_DB, :verbose => true)# if File.exists?(AR_DB)
  end
  
  def test_album_cache
    assert true
    res = ArAlbumCache.get(:recent_albums, 5)
    assert_not_nil res
    assert res.is_a?(Array)
    assert_equal 5, res.size
    res.each do |r|
       assert r.is_a?(ArAlbum)
    end
  end
  
  def test_extensions
    album = ArAlbum.find(1)
    assert !Cachetastic::Caches::ActiveRecord.const_defined?("ArAlbumCache")
    album.cache_self
    assert Cachetastic::Caches::ActiveRecord.const_defined?("ArAlbumCache")
    assert_equal album, Cachetastic::Caches::ActiveRecord::ArAlbumCache.get(1)
    
    song = ArSong.find(1)
    assert !Cachetastic::Caches::ActiveRecord.const_defined?("ArSongCache")
    song.cache_self
    assert Cachetastic::Caches::ActiveRecord.const_defined?("ArSongCache")
    assert_equal song, Cachetastic::Caches::ActiveRecord::ArSongCache.get(1)
    assert_equal album, Cachetastic::Caches::ActiveRecord::ArAlbumCache.get(1)
    
    song.uncache_self
    assert_nil Cachetastic::Caches::ActiveRecord::ArSongCache.get(1)
    
    ac = ArAlbum.get_from_cache(1)
    assert_not_nil ac
    assert_equal album, ac
    
    ArAlbum.delete_from_cache(1)
    ac = ArAlbum.get_from_cache(1)
    assert_nil ac
    
    ac = ArAlbum.set_into_cache(1, album)
    assert_not_nil ac
    assert_equal album, ac
    
    ac = ArAlbum.cacher(:foobar) do
      ArAlbum.find(2)
    end
    
    assert_not_nil ac
    assert_equal ArAlbum.find(2), ac
    
    ac = ArAlbum.get_from_cache(:foobar)
    assert_not_nil ac
    assert_equal ArAlbum.find(2), ac
    
    assert_equal [1,2,3,:yippie], ac.some_numbers([1,2,3])
    assert_equal [1,2,3,:yippie], ArAlbum.get_from_cache(:some_numbers)
    assert_equal [1,2,3,:yippie], ac.some_numbers([1,2,3,4,5,6])
    
    ArAlbum.delete_from_cache(1)
    ac = ArAlbum.get_from_cache(1)
    assert_nil ac
    ac = ArAlbum.get_from_cache(1, true)
    assert_not_nil ac
  end
  
end