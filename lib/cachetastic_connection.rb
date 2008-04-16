# This class caches adapter objects for each cache in the system.
class Cachetastic::Connection
  include Singleton
  
  attr_accessor :connections
  
  def initialize
    self.connections = {}
  end
  
  # Takes the name of the cache, that's been methodized, and returns back the adapter object associated with the cache.
  # If the adapter object doesn't exist or if the adapter is no longer valid (adapter.valid?) a new one is
  # created and returned.
  def get(name)
    name = name.to_sym
    conn = self.connections[name]
    return conn if conn && conn.valid?
    adapter = Cachetastic::Adapters::Base.get_options(name)["adapter"].camelcase
    conn = "Cachetastic::Adapters::#{adapter}".constantize.new(name)
    self.connections[name.to_sym] = conn
    return conn
  end
  
end