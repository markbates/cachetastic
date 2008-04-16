class Cachetastic::Errors::UnsupportedAdapter < Exception
  
  def initialize(cache_name, adapter)
    super("#{cache_name} does not support the use of the #{adapter} adapter!")
  end
  
end