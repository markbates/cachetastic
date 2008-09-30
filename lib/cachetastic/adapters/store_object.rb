class Cachetastic::Adapters::StoreObject #:nodoc:#
  attr_accessor :key
  attr_accessor :value
  attr_accessor :expires_at
  
  def initialize(key, value, expiry)
    self.key = key
    self.value = value
    begin
      self.expires_at = (Time.now + (expiry == 0 ? (31536000) : expiry)) # 31536000 = one year
    rescue RangeError => e
      self.expires_at = Time.at(expiry)
    end
    # puts "now: #{Time.now}"
    # puts "expiry: #{expiry}"
    # puts "expires_at: #{self.expires_at}"
  end
  
  def size
    return self.value.size if self.value.respond_to?(:size)
    -1
  end
  
  def invalid?
    Time.now >= self.expires_at
  end
  
end