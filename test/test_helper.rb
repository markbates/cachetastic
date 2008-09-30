require "test/unit"
require File.join(File.dirname(__FILE__), "..", "lib", "cachetastic")
require 'rubygems'
require 'mack-facets'
require 'active_record'

# place common methods, assertions, and other type things in this file so
# other tests will have access to them.

require File.join(File.dirname(__FILE__), "config")

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

class YoungMcCache < Cachetastic::Caches::Base
end

class DrBobCache < Cachetastic::Caches::Base
end


#---- AR:
AR_DB = File.join(Dir.pwd, "ar_test.db")
puts "AR_DB: #{AR_DB}"
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
  def self.down
    drop_table :ar_songs
    drop_table :ar_albums
  end
end