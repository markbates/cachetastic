# This adapter uses the file system as it's backing.
# Caches are stored in files called index.html.
# At the beginning of the html the following html comments are pre-pended:
#   <!-- cachetastic: expires_at: Fri Feb 01 20:51:45 -0500 2008 -->
#   <!-- cachetastic: key: /channels/1-arts-humanities --> 
# Obviously the expires_at date will be the ACTUAL expire date,
# same goes for the key.
# The configuration for this should look something like this:
#  my_awesome_cache_options:
#    debug: false
#    adapter: html_file
#    marshall_method: none
#    default_expiry: <%= 24.hours %>
#    store_options:  
#      dir: /usr/local/caches/
#    logging:
#      logger_1:
#        type: file
#        file: log/file_store_cache.log
require 'time'
class Cachetastic::Adapters::HtmlFile < Cachetastic::Adapters::FileBase
  
  def get(key)
    full_path = full_path_from_dir(get_key_directoy(key, false))
    return nil unless File.exists?(full_path)
    so = html_to_store_object(File.open(full_path).read)
    if so
      if so.invalid?
        self.delete(key)
        return nil
      end
      return so.value
    end
    return nil
  end
  
  def set(key, value, expiry = 0)
    so = Cachetastic::Adapters::StoreObject.new(key.to_s, value, expiry)
    File.open(full_path_from_key(key), "w") do |f|
      f.puts store_object_to_html(so)
    end
  end
  
  protected
  def store_file_name
    return STORE_FILE_NAME
  end
  
  private
  def html_to_store_object(html)
    key = html.match(/<!-- cachetastic: key: (.*) -->/).captures.first
    expires_at = html.match(/<!-- cachetastic: expires_at: (.*) -->/).captures.first
    html.gsub!(/<!-- cachetastic: key: .* -->/, '')
    html.gsub!(/<!-- cachetastic: expires_at: .* -->/, '')
    so = Cachetastic::Adapters::StoreObject.new(key, html, 0)
    so.expires_at = Time.parse(expires_at)
    so
  end
  
  def store_object_to_html(so)
    x = so.value
    x << "\n<!-- cachetastic: expires_at: #{so.expires_at} -->"
    x << "\n<!-- cachetastic: key: #{so.key} -->"
  end
  
  STORE_FILE_NAME = "index.html"
  
end