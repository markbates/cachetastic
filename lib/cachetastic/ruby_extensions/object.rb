class Object
  
  # Override this method in your object if you use the Cachetastic::Cacheable module.
  def cachetastic_key
    raise NoMethodError.new('cachetastic_key')
  end
  
  unless respond_to?(:ivar_cache)
    def ivar_cache(var_name = nil, &block)
      if var_name.nil?
        call = caller[0]
        var_name = call[(call.index('`')+1)...call.index("'")]
      end
      var = instance_variable_get("@#{var_name}")
      unless var
        return instance_variable_set("@#{var_name}", yield) if block_given?
      end
      instance_variable_get("@#{var_name}")
    end
  end
  
end