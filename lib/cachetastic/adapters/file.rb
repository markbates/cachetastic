# This adapter uses the file system as it's backing.
# The configuration for this should look something like this:
#  my_awesome_cache_options:
#    debug: false
#    adapter: file
#    marshall_method: none
#    default_expiry: <%= 24.hours %>
#    store_options:  
#      dir: /usr/local/caches/
#    logging:
#      logger_1:
#        type: file
#        file: log/file_store_cache.log
class Cachetastic::Adapters::File < Cachetastic::Adapters::FileBase
  
  def get(key)
    full_path = full_path_from_dir(get_key_directoy(key, false))
    return nil unless File.exists?(full_path)
    so = YAML::load(File.open(full_path).read)
    if so
      if so.invalid?
        self.delete(key)
        return nil
      end
      if so.value.is_a?(YAML::Object)
        require so.value.class.underscore
        so = YAML::load(File.open(full_path).read)
      end
      return so.value
    end
    return nil
  end
  
  def set(key, value, expiry = 0)
    so = Cachetastic::Adapters::StoreObject.new(key.to_s, value, expiry)
    File.open(full_path_from_key(key), "w") do |f|
      f.puts YAML.dump(so)
    end
  end
  
  protected
  def store_file_name
    return STORE_FILE_NAME
  end
  
  private
  STORE_FILE_NAME = "cache.yml"
  
end