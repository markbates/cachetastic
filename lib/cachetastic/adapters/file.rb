module Cachetastic
  module Adapters
    class File < Cachetastic::Adapters::Base
      
      def initialize(klass)
        define_accessor(:storage_path)
        self.storage_path = ::File.join(FileUtils.pwd, 'cachetastic')
        super
        self.marshal_method = :yaml if self.marshal_method == :none
        @_file_paths = {}
      end
      
      def get(key, &block)
        path = file_path(key)
        val = nil
        val = ::File.read(path) if ::File.exists?(path)
        return val
      end # get
      
      def set(key, value, expiry_time = configatron.cachetastic.defaults.default_expiry)
        so = Cachetastic::Cache::StoreObject.new(key, value, expiry_time.from_now)
        path = file_path(key)
        ::File.open(path, 'w') {|f| f.write marshal(so)}
        value
      end # set
      
      def delete(key)
        FileUtils.rm(file_path(key))
      end # delete
      
      def expire_all
        @_file_paths = {}
        ::FileUtils.rm_rf(::File.join(self.storage_path, klass.name.underscore))
        return nil
      end # expire_all
      
      def transform_key(key)
        key.to_s.hexdigest
      end
      
      def file_path(key)
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