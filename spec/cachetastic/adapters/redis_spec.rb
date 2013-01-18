require 'spec_helper'

describe Cachetastic::Adapters::Redis do

  describe "connection" do

    it "respects the configatron.defaults.redis_host option" do
      configatron.temp do
        configatron.cachetastic.defaults.redis_host = "redis://example.com:1234/"
        ::Redis.should_receive(:new).with({
          url: "redis://example.com:1234/",
          scheme: "redis",
          host: "example.com",
          port: 1234,
          path: nil,
          timeout: 5.0,
          password: nil,
          db: "cachetastic",
          driver: nil,
          id: nil,
          tcp_keepalive: 0
        })
        adapter = Cachetastic::Adapters::Redis.new(CarCache)
      end
    end

  end

end
