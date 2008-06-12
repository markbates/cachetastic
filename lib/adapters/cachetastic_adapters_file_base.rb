require 'digest/md5'
require 'base64'
class Cachetastic::Adapters::FileBase < Cachetastic::Adapters::Base
  
  attr_reader :directory
  attr_reader :hashed_keys
  
  def setup
    @directory = File.join(self.configuration.store_options.dir, self.name.to_s)
    FileUtils.mkdir_p(self.directory, :verbose => self.debug?)
    @hashed_keys = {}
  end
  
  def valid?
    File.exists?(self.directory)
  end
  
  def stats
    super
    num_files = num_directories = file_size = 0
    everything = Dir.glob("#{self.directory}/**/*")
    everything.reject{|x| x =~ /^\./}.each do |entry|
      if ::File.directory?(entry)
        num_directories +=  1
      else
        file_size += ::File.size(entry)
        num_files += 1
      end
    end
    puts "Number of Files: #{num_files}\nNumber of Directories: #{num_directories}\nTotal Size on Disk: #{file_size/1024.to_f} KB\n\n"
  end
  
  def delete(key, delay = 0)
    if delay <= 0
      FileUtils.rm_rf(get_key_directoy(key), :verbose => self.debug?)
    else
      so = self.get(key)
      if so
        self.set(so.key, so.value, delay)
      end
    end
  end
  
  def expire_all
    FileUtils.rm_rf(self.directory, :verbose => self.debug?)
    setup
  end
  
  protected
  def store_file_name
    return "cachetastic.data"
  end
  
  private
  def directory_from_key(key)
    hkey = Base64.encode64(Digest::MD5.digest(key))
    hkey.gsub!("==\n", "")
    i = 0
    path = ""
    until i >= hkey.length do
      path = File.join(path, hkey[i..i+2])
      i += 3
    end
    path
  end
  
  def full_path_from_key(key)
    full_path_from_dir(get_key_directoy(key))
  end
  
  def full_path_from_dir(dir)
    File.join(dir, store_file_name)
  end
  
  def get_key_directoy(key, mkdir = true)
    hkey = self.hashed_keys[key.to_sym]
    if hkey.nil?
      path = File.join(self.directory, directory_from_key(key))
      self.hashed_keys[key.to_sym] = path
      hkey = path
    end
    FileUtils.mkdir_p(hkey, :verbose => self.debug?) if mkdir
    hkey
  end
  
end