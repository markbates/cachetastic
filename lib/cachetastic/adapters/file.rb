module Cachetastic
  module Adapters
    class File < Cachetastic::Adapters::Base
      
      def initialize(klass)
        define_accessor(:storage_path)
        self.storage_path = ::File.join(FileUtils.pwd, 'cachetastic', klass.name.underscore)
        super
        self.marshal_method = :yaml if self.marshal_method == :none
      end
      
      def get(key, &block)
        path = file_path(key)
        val = nil
        if ::File.exists?(path)
          val = unmarshal(::File.read(path))
        end
        
        handle_store_object(key, val, &block)
      end # get
      
      def set(key, value, expiry_time = nil)
        so = Cachetastic::Cache::StoreObject.new(key, value, calculate_expiry_time(expiry_time).from_now)
        path = file_path(key)
        FileUtils.mkdir_p(::File.dirname(path))
        ::File.open(path, 'w') {|f| f.write marshal(so)}
        value
      end # set
      
      def delete(key)
        FileUtils.rm(file_path(key))
      end # delete
      
      def expire_all
        begin
          FileUtils.rm_r(self.storage_path)
        rescue Errno::ENOENT => e
        end
      end # expire_all
      
      def transform_key(key)
        key.to_s.hexdigest
      end
      
      def file_path(key)
        ::File.join(self.storage_path, transform_key(key).scan(/(.{1,3})/).flatten, 'cache.txt')
      end
      
    end # File
  end # Adapters
end # Cachetastic