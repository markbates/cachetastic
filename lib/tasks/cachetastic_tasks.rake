require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'
require 'find'
require 'fileutils'
require 'rubyforge'
require 'ruby_forge_config'
namespace :rgem do
  
  namespace :rdoc do
    
    desc "Rdoc the cachetastic gem."
    task :cachetastic do |t|
      rfc = RubyForgeConfig.load(__FILE__)
      pwd = FileUtils.pwd
      FileUtils.cd "#{RAILS_ROOT}/vendor/plugins/#{rfc.gem_name}"
      FileUtils.rm_rf 'doc', :verbose => true
      puts `rdoc --title Cachetastic --main lib/cachetastic.rb`
      FileUtils.cp "README", "doc/README"
      FileUtils.cd pwd
    end
    
  end
  
  namespace :package  do
  
    desc "Package up the cachetastic gem."
    task :cachetastic do |t|
      rfc = RubyForgeConfig.load(__FILE__)
      pwd = FileUtils.pwd
      FileUtils.cd "#{RAILS_ROOT}/vendor/plugins/#{rfc.gem_name}"
      gem_spec = Gem::Specification.new do |s|
        s.name = rfc.gem_name
        s.version = rfc.version
        s.summary = rfc.gem_name
        s.description = %{#{rfc.gem_name} was developed by: markbates}
        s.author = "markbates"
        s.has_rdoc = true
        s.extra_rdoc_files = ["README"]
        s.files = FileList["README", "**/*.*"].exclude("pkg").exclude("#{rfc.gem_name}_tasks.rake").exclude("init.rb").exclude("doc")
        s.require_paths << 'lib'# << 'doc'
        
        s.bindir = "bin"
        s.executables << "cachetastic_drb_server"
        
        s.rdoc_options << '--title' << 'Cachetastic-RDoc' << '--main' << 'README' << '--line-numbers' << "--inline-source"
        
        # This will loop through all files in your lib directory and autorequire them for you.
        # It will also ignore all Subversion files.
        s.autorequire = []
      
        s.autorequire = ['cachetastic']
      
        # ["lib"].each do |dir|
        #   Find.find(dir) do |f|
        #     if FileTest.directory?(f) and !f.match(/.svn/)
        #       s.require_paths << f
        #     else
        #       if FileTest.file?(f)
        #         m = f.match(/\/[a-zA-Z-_]*.rb/)
        #         if m
        #           model = m.to_s
        #           unless model.match("test_")
        #             #puts "model = #{model}"
        #             x = model.gsub('/', '').gsub('.rb', '')
        #             s.autorequire << x
        #           end
        #           #puts x
        #         end
        #       end
        #     end
        #   end
        # end

        s.rubyforge_project = rfc.project
      end
      Rake::GemPackageTask.new(gem_spec) do |pkg|
        pkg.package_dir = "#{RAILS_ROOT}/pkg"
        pkg.need_zip = false
        pkg.need_tar = false
      end
      Rake::Task["package"].invoke
      FileUtils.cd pwd
    end
  
  end
  
  namespace :install do
    
    desc "Package up and install the cachetastic gem."
    task :cachetastic => "rgem:package:cachetastic" do |t|
      rfc = RubyForgeConfig.load(__FILE__)
      rfc.install("#{RAILS_ROOT}/pkg")
    end
    
  end
  
  namespace :release do
    
    desc "Package up, install, and release the cachetastic gem."
    task :cachetastic => ["rgem:install:cachetastic"] do |t|
      rfc = RubyForgeConfig.load(__FILE__)
      rfc.release
    end
    
  end
  
end

desc "Test Cachetastic"
Rake::TestTask.new(:cache => "test:setup") do |t|
  t.libs << "test"
  t.pattern = 'test/**/cachetastic/*_test.rb'
  t.verbose = true
end