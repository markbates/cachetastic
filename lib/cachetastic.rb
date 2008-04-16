# :include: README
require 'rubygems'
require 'singleton'
require 'logger'
require 'yaml'
require 'zlib'
require 'pp'
require 'drb'
require 'application_configuration'
begin
  require 'memcache'
rescue Exception => e
  # if you don't have memcache installed, don't 
  # blow up, print a message, and you can't use
  # the memcache adapter.
  puts e.message
end


module Cachetastic #:nodoc:#
  module Caches #:nodoc:#
    module ActiveRecord #:nodoc:#
    end
  end
  module Adapters #:nodoc:#
  end
  module Errors #:nodoc:#
  end
  module Helpers #:nodoc:#
    module ActiveRecord #:nodoc:#
    end
  end
end
module ActiveRecord #:nodoc:#
end

require 'cachetastic_connection'
require 'cachetastic_logger'
require 'caches/cachetastic_caches_base'
require 'caches/cachetastic_caches_page_cache'
require 'caches/cachetastic_caches_rails_session_cache'
require 'caches/cachetastic_caches_mack_session_cache'
require 'errors/cachetastic_errors_unsupported_adapter'
require 'adapters/cachetastic_adapters_base'
require 'adapters/cachetastic_adapters_store_object'
require 'adapters/cachetastic_adapters_memcache'
require 'adapters/cachetastic_adapters_local_memory'
require 'adapters/cachetastic_adapters_file_base'
require 'adapters/cachetastic_adapters_file'
require 'adapters/cachetastic_adapters_html_file'
require 'adapters/cachetastic_adapters_drb'
require 'helpers/cachetastic_helpers_active_record'
require 'rails_extensions/cachetastic_active_record_base'
require 'rails_extensions/cgi_session_cachetastic_store'

#--
# http://rdoc.sourceforge.net/doc/index.html
#++