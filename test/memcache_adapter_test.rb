require File.join(File.dirname(__FILE__), "test_helper")

class MemcacheAdapterTest < Test::Unit::TestCase
  
  def setup
    # YoungMcCache.expire_all
  end
  
  def test_memcache_adapter
    assert_nil YoungMcCache.get(1)
    assert YoungMcCache.adapter.valid?
    YoungMcCache.set(1, :one)
    assert_equal :one, YoungMcCache.get(1)
    YoungMcCache.expire_all
    assert_nil YoungMcCache.get(1)
  end
  
end