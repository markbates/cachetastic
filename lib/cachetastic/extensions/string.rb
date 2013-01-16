require 'digest'
class String # :nodoc:
  
  def hexdigest # :nodoc:
    Digest::SHA1.hexdigest(self)
  end
  
end