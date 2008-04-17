require "test/unit"
require File.join(File.dirname(__FILE__), "..", "lib", "cachetastic")
require 'mack_ruby_core_extensions'
require 'active_record'
require 'data_mapper'

# place common methods, assertions, and other type things in this file so
# other tests will have access to them.

app_config.load_file(File.join(File.dirname(__FILE__), "config.yml"))

class MyTempOptionsCache < Cachetastic::Caches::Base
end

class YourTempOptionsCache < Cachetastic::Caches::Base
end

class MyFileStoreCache < Cachetastic::Caches::Base
end

class FooBarCache < Cachetastic::Caches::Base
end

class ArAlbumCache < Cachetastic::Caches::Base
  class << self
    def get(key, num)
      logger.info(key, num)
      super(key) do
        a = []
        num.times do
          a << ArAlbum.find(1)
        end
        set(key, a)
      end
    end # get
  end # self
end # AlbumCache


#---- AR:
AR_DB = File.join(File.dirname(__FILE__), "ar_test.db")
ActiveRecord::Base.establish_connection({:adapter => "sqlite3", :database => AR_DB})

class ArAlbum < ActiveRecord::Base
  def some_numbers(arr)
    cacher(:some_numbers) do
      arr << :yippie
    end
  end
end
class ArSong < ActiveRecord::Base
end

class ArMigration < ActiveRecord::Migration
  def self.up
    create_table :ar_albums do |t|
      t.column :title, :string
      t.column :artist, :string
    end
    create_table :ar_songs do |t|
      t.column :title, :string
      t.column :album_id, :integer
    end
  end
end

#---- DB: 
DM_DB = File.join(File.dirname(__FILE__), "dm_test.db")
DataMapper::Database.setup({:adapter => "sqlite3", :database => DM_DB})

class DmAlbum < DataMapper::Base
  property :title, :string
  property :artist, :string
  def some_numbers(arr)
    cacher(:some_numbers) do
      arr << :yippie
    end
  end
end

class DmSong < DataMapper::Base
  property :title, :string
  property :album_id, :integer
end