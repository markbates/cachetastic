val = %{
  Velit esse molestie consequat vel illum dolore eu. Blandit praesent luptatum zzril delenit augue duis dolore te feugait.

  Duis dolore te feugait nulla facilisi nam liber tempor cum soluta nobis eleifend! Commodo consequat duis autem vel eum iriure dolor. Quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea in hendrerit. Qui blandit praesent luptatum zzril delenit augue option congue. Typi qui nunc nobis videntur parum clari fiant sollemnes in. Lectorum mirum est notare quam littera gothica quam nunc putamus parum claram anteposuerit litterarum. Typi non habent claritatem insitam est usus legentis in?

  Humanitatis per seacula quarta decima et quinta decima eodem modo typi qui nunc nobis videntur. Putamus parum claram anteposuerit litterarum formas parum clari fiant sollemnes in. Legentis in iis qui facit eorum claritatem Investigationes. Aliquip ex ea commodo consequat duis autem: vel eum iriure dolor in hendrerit in vulputate.
}.strip

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'cachetastic'))
require 'benchmark'

class PerformanceTestCache
  include Cachetastic::Cache
end

times_to_run = 1000
results = {}

# [Cachetastic::Adapters::LocalMemory, Cachetastic::Adapters::Memcached, Cachetastic::Adapters::File].each do |adapter|
[Cachetastic::Adapters::File].each do |adapter|
# [Cachetastic::Adapters::Memcached].each do |adapter|
  puts "Starting benchmark for: #{adapter}:"
  configatron.cachetastic.defaults.adapter = adapter
  if adapter == Cachetastic::Adapters::File
    configatron.cachetastic.defaults.storage_path = '/cachetastic'
  end
  PerformanceTestCache.clear_adapter!
  results[adapter] = Benchmark.realtime {
    times_to_run.times do
      PerformanceTestCache.get(:foo)
      PerformanceTestCache.set(:foo, val)
      PerformanceTestCache.get(:foo)
      PerformanceTestCache.delete(:foo)
      10.times do |i|
        PerformanceTestCache.set(i, val)
        10.times do
          PerformanceTestCache.get(i)
        end
      end
      PerformanceTestCache.expire_all
    end
  }
  puts "Finished benchmark for: #{adapter}"
end

results.each do |adapter, time|
  puts "#{adapter}: #{time} (avg. #{time / times_to_run.to_f})"
end

# v2.1.4:
# file:                               100.953929901123  (avg. 0.100953929901123)
# memcache:                           59.0524849891663  (avg. 0.0590524849891663)
# local_memory:                       20.7526040077209  (avg. 0.0207526040077209)

# v2.9.9:
# Cachetastic::Adapters::File:        137.059388160706  (avg. 0.137059388160706)    (-26%)
# Cachetastic::Adapters::Memcached:   47.6220090389252  (avg. 0.0476220090389252)   (20%)
# Cachetastic::Adapters::LocalMemory: 1.49835991859436  (avg. 0.00149835991859436)  (99%)

