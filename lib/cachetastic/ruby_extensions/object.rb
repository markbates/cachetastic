class Object
  
  # Override this method in your object if you use the Cachetastic::Cacheable module.
  def cachetastic_key
    raise NoMethodError.new('cachetastic_key')
  end
  
end