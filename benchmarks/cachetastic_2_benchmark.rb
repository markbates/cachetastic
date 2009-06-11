val = %{
  Velit esse molestie consequat vel illum dolore eu. Blandit praesent luptatum zzril delenit augue duis dolore te feugait.

  Duis dolore te feugait nulla facilisi nam liber tempor cum soluta nobis eleifend! Commodo consequat duis autem vel eum iriure dolor. Quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea in hendrerit. Qui blandit praesent luptatum zzril delenit augue option congue. Typi qui nunc nobis videntur parum clari fiant sollemnes in. Lectorum mirum est notare quam littera gothica quam nunc putamus parum claram anteposuerit litterarum. Typi non habent claritatem insitam est usus legentis in?

  Humanitatis per seacula quarta decima et quinta decima eodem modo typi qui nunc nobis videntur. Putamus parum claram anteposuerit litterarum formas parum clari fiant sollemnes in. Legentis in iis qui facit eorum claritatem Investigationes. Aliquip ex ea commodo consequat duis autem: vel eum iriure dolor in hendrerit in vulputate.
}.strip

gem 'cachetastic', '2.1.4'
require 'cachetastic'
require 'benchmark'

class PerformanceTestCache < Cachetastic::Caches::Base # :nodoc:
end

times_to_run = 1000
results = {}

[:local_memory, :file, :memcache].each do |adapter|
# [:memcache].each do |adapter|
  puts "Starting benchmark for: #{adapter}:"
  configatron.cachetastic_default_options.adapter = adapter
  logger = ::Logger.new(STDOUT)
  logger.level = ::Logger::ERROR
  configatron.cachetastic_default_options.logger = [logger]
  case adapter
  when :file
    configatron.cachetastic_default_options.store_options.dir = "/cachetastic/caches"
  when :memcache
    configatron.cachetastic_default_options.servers = ["127.0.0.1:11211"]
    configatron.cachetastic_default_options.store_options.c_threshold = "10_000"
    configatron.cachetastic_default_options.store_options.compression = true
    configatron.cachetastic_default_options.store_options.debug = false
    configatron.cachetastic_default_options.store_options.readonly = false
    configatron.cachetastic_default_options.store_options.urlencode = false
  end
  Cachetastic::Connection.instance.connections.clear
  results[adapter] = Benchmark.realtime {
    times_to_run.times do
      PerformanceTestCache.get(:foo)
      PerformanceTestCache.set(:foo, val)
      PerformanceTestCache.get(:foo)
      PerformanceTestCache.delete(:foo)
      10.times do |i|
        PerformanceTestCache.set(i, val)
        PerformanceTestCache.get(i)
      end
      PerformanceTestCache.expire_all
    end
  }
  puts "Finished benchmark for: #{adapter}"
end

results.each do |adapter, time|
  puts "#{adapter}: #{time} (avg. #{time / times_to_run.to_f})"
end

# file:         100.953929901123  (avg. 0.100953929901123)
# local_memory: 20.7526040077209  (avg. 0.0207526040077209)
# memcache:     59.0524849891663  (avg. 0.0590524849891663)
# local_memory: 20.2518169879913 (avg. 0.0202518169879913)
# memcache: 82.2444090843201 (avg. 0.0822444090843201)
# file: 95.6928708553314 (avg. 0.0956928708553314)
