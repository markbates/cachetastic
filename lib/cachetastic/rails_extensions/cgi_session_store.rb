require 'cgi'
require 'cgi/session'

class CGI #:nodoc:#
  class Session #:nodoc:#
    # Allows Rails to use Cachetastic for it's session store.
    # The setting below needs to happen AFTER the gem has been required, obviously!
    # In Rails 1.2.6 this is AFTER the initializer block.
    #   ActionController::Base.session_store = :cachetastic_store
    class CachetasticStore


      def check_id(id) #:nodoc:#
        /[^0-9a-zA-Z]+/ =~ id.to_s ? false : true
      end
      
      def initialize(session, options = {}) #:nodoc:#
        id = session.session_id
        unless check_id(id)
          raise ArgumentError, "session_id '%s' is invalid" % id
        end
        
        @session_key = id
        
        @session_data = {}
      end
 
      # Restore session state from the session's memcache entry.
      #
      # Returns the session state as a hash.
      def restore #:nodoc:#
        @session_data = Cachetastic::Caches::RailsSessionCache.get(@session_key) do
          {}
        end
      end

      # Save session state to the session's memcache entry.
      def update #:nodoc:#
        Cachetastic::Caches::RailsSessionCache.set(@session_key, @session_data)
      end
    
      # Update and close the session's memcache entry.
      def close #:nodoc:#
        update
      end

      # Delete the session's memcache entry.
      def delete #:nodoc:#
        Cachetastic::Caches::RailsSessionCache.delete(@session_key)
        @session_data = {}
      end
      
      def data #:nodoc:#
        @session_data
      end

    end
  end
end
