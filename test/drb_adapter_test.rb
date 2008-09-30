require File.join(File.dirname(__FILE__), "test_helper")

class DrbAdapterTest < Test::Unit::TestCase
  
  def test_drb_adapter
    assert_nil DrBobCache.get(1)
    assert DrBobCache.adapter.valid?
    DrBobCache.set(1, :one)
    assert_equal :one, DrBobCache.get(1)
    DrBobCache.expire_all
    assert_nil DrBobCache.get(1)
  end
  
end