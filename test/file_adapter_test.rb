require File.join(File.dirname(__FILE__), "test_helper")

class FileAdapterTest < Test::Unit::TestCase
  
  C_DIR = app_config.my_file_store_cache_options["store_options"]["dir"]
  
  def setup
    FileUtils.rm_rf(C_DIR, :verbose => true)
  end
  
  def test_directory_created_if_it_doesnt_exist_on_new
    assert !File.exists?(C_DIR)
    assert_nil MyFileStoreCache.get(1)
    assert File.exists?(C_DIR)
    assert MyFileStoreCache.adapter.valid?
  end
  
  def test_invalid_if_directory_is_deleted
    assert !File.exists?(C_DIR)
    assert_nil MyFileStoreCache.get(1)
    assert File.exists?(C_DIR)
    FileUtils.rm_rf(C_DIR, :verbose => true)
    assert !Cachetastic::Connection.instance.connections[:my_file_store_cache].valid?
  end
  
  def test_expire_all
    assert_nil MyFileStoreCache.get(1)
    MyFileStoreCache.set(1, "hello")
    assert_equal "hello", MyFileStoreCache.get(1)
    assert_nil MyFileStoreCache.get(2)
    MyFileStoreCache.set(2, [1,2,3,4])
    assert_equal [1,2,3,4], MyFileStoreCache.get(2)
    MyFileStoreCache.expire_all
    assert_equal nil, MyFileStoreCache.get(1)
    assert_equal nil, MyFileStoreCache.get(2)
  end
  
  def test_expiry
    assert_nil MyFileStoreCache.get(1)
    MyFileStoreCache.set(1, "hello", 1.second)
    assert_equal "hello", MyFileStoreCache.get(1)
    sleep(3)
    assert_nil MyFileStoreCache.get(1)
  end
  
end