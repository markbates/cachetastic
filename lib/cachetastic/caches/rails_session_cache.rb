# Used for storing Rails sessions.
class Cachetastic::Caches::RailsSessionCache < Cachetastic::Caches::Base
  
  class << self
    
    def unsupported_adapters
      [Cachetastic::Adapters::File]
    end
    
  end
  
end