module Cachetastic # :nodoc:
  module Adapters
    # An adapter to cache objects to the file system.
    # 
    # This adapter supports the following configuration settings,
    # in addition to the default settings:
    # 
    #   configatron.cachetastic.defaults.storage_path = ::File.join(FileUtils.pwd, 'cachetastic')
    #   configatron.cachetastic.defaults.marshal_method = :yaml
    # 
    # The <tt>storage_path</tt> setting defines the path to where cached
    # objects are written to on disk.
    # 
    # See <tt>Cachetastic::Adapters::Base</tt> for a list of public API
    # methods.
    class File < Cachetastic::Adapters::Base
      
      def initialize(klass) # :nodoc:
        define_accessor(:storage_path)
        self.storage_path = ::File.join(FileUtils.pwd, 'cachetastic')
        super
        self.marshal_method = :yaml if self.marshal_method == :none
        @_file_paths = {}
      end
      
      def get(key) # :nodoc:
        path = file_path(key)
        val = nil
        val = ::File.read(path) if ::File.exists?(path)
        return val
      end # get
      
      def set(key, value, expiry_time = configatron.cachetastic.defaults.default_expiry) # :nodoc:
        so = Cachetastic::Cache::StoreObject.new(key, value, expiry_time.from_now)
        path = file_path(key)
        ::File.open(path, 'w') {|f| f.write marshal(so)}
        value
      end # set
      
      def delete(key) # :nodoc:
        path = file_path(key)
        if ::File.exists?(path)
          FileUtils.rm(path)
        end
      end # delete
      
      def expire_all # :nodoc:
        @_file_paths = {}
        ::FileUtils.rm_rf(::File.join(self.storage_path, klass.name.underscore))
        return nil
      end # expire_all
      
      def transform_key(key) # :nodoc:
        key.to_s.hexdigest
      end
      
      def file_path(key) # :nodoc:
        path = @_file_paths[key]
        if path.nil?
          path = ::File.join(self.storage_path, klass.name.underscore, transform_key(key).scan(/(.{1,4})/).flatten, 'cache.data')
          @_file_paths[key] = path
          FileUtils.mkdir_p(::File.dirname(path))
        end
        return path
      end
      
    end # File
  end # Adapters
end # Cachetastic