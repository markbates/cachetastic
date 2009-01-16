module Kernel # :nodoc:
  
  def retryable(options = {}, &block) # :nodoc:
    opts = { :tries => 1, :on => Exception }.merge(options)

    retries = opts[:tries]
    retry_exceptions = [opts[:on]].flatten
    
    x = %{
      begin
        return yield
      rescue #{retry_exceptions.join(", ")} => e
        retries -= 1
        if retries > 0
          retry
        else
          raise e
        end
      end        
    }

    eval(x, &block)
  end
  
end