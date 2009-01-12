# :include: README
require 'rubygems'
require 'singleton'
require 'logger'
require 'yaml'
require 'zlib'
require 'pp'
require 'drb'
require 'configatron'
require 'mack-facets'
begin
  require 'memcache'
rescue Exception => e
  # if you don't have memcache installed, don't 
  # blow up, print a message, and you can't use
  # the memcache adapter.
  puts "CACHETASTIC: Warning: You don't have the memcache gem installed which means you can't use the Cachetastic::Adapters::Memcache adapter."
end

class Object
  # Uses <code>define_method</code> to create an empty for the method parameter defined.
  # That method will then raise MethodNotImplemented. This is useful for creating interfaces
  # and you want to stub out methods that others need to implement.
  def self.needs_method(meth)
    define_method(meth) do
      raise NoMethodError.new("The interface you are using requires you define the following method '#{meth}'")
    end
  end
end

module Cachetastic #:nodoc:#
  module Caches #:nodoc:#
  end
  module Adapters #:nodoc:#
  end
  module Errors #:nodoc:#
  end
  module Cacheable
  end
end
module ActiveRecord #:nodoc:#
end

home = File.join(File.dirname(__FILE__), 'cachetastic')

require File.join(home, 'connection')
require File.join(home, 'logger')
require File.join(home, 'caches/base')
require File.join(home, 'caches/page_cache')
require File.join(home, 'caches/rails_session_cache')
require File.join(home, 'caches/mack_session_cache')
require File.join(home, 'errors/unsupported_adapter')
require File.join(home, 'adapters/base')
require File.join(home, 'adapters/store_object')
require File.join(home, 'adapters/memcache')
require File.join(home, 'adapters/local_memory')
require File.join(home, 'adapters/file_base')
require File.join(home, 'adapters/file')
require File.join(home, 'adapters/html_file')
require File.join(home, 'adapters/drb')
require File.join(home, 'cacheable')
require File.join(home, 'rails_extensions/active_record_base')
require File.join(home, 'rails_extensions/cgi_session_store')

configatron.cachetastic_default_options.set_default(:debug, false)
configatron.cachetastic_default_options.set_default(:adapter, :local_memory)
configatron.cachetastic_default_options.set_default(:logger, ::Logger.new(STDOUT))

#--
# http://rdoc.sourceforge.net/doc/index.html
#++