require File.join(File.dirname(__FILE__), "test_helper")

class MyTempOptionsCache < Cachetastic::Caches::Base
end

class YourTempOptionsCache < Cachetastic::Caches::Base
end

class CachetasticOptionsTest < Test::Unit::TestCase

  def test_truth
    default_options = {"debug" => true, "adapter" => "local_memory", "marshall_method" => "none", "default_expiry" => 24.hours, "logging" => {"logger_2" => {"type" => "console", "level" => :debug}}}
    assert_equal default_options, MyTempOptionsCache.adapter.all_options
    
    assert_equal default_options.merge("adapter" => "file", "store_options" => {"dir" => "/cachetastic/test"}), YourTempOptionsCache.adapter.all_options
    
    assert_equal default_options.merge("default_expiry" => 3.seconds, "marshall_method" => "yaml"), FooBarCache.adapter.all_options
    
  end
  
end