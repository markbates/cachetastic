ENV["RACK_ENV"] ||= "test"

require 'bundler/setup'

require 'cachetastic' # and any other gems you need
require 'timecop'

RSpec.configure do |config|

  config.before do
    Timecop.freeze
  end

  config.after do
    Timecop.return
  end

end

class CarCache < Cachetastic::Cache
end

class Cachetastic::BlockError < StandardError
end