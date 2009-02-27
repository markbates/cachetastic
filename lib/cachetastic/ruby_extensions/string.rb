class String
  
  unless ''.respond_to?(:camelcase)
    def camelcase
      to_s.gsub(/\/(.?)/){ "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/){ $1.upcase }
    end
  end
  
  unless ''.respond_to?(:constantize)
    def constantize
      Module.instance_eval("::#{self}")
    end
  end
  
end