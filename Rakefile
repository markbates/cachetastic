require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'find'
require 'rubyforge'
require 'rubygems'
require 'rubygems/gem_runner'

@gem_spec = Gem::Specification.new do |s|
  s.name = 'cachetastic'
  s.version = '2.0.0'
  s.summary = "A very simple, yet very powerful caching framework for Ruby."
  s.description = "A very simple, yet very powerful caching framework for Ruby."
  s.author = "markbates"
  s.email = "mark@mackframework.com"
  s.homepage = "http://www.mackframework.com"

  s.test_files = FileList['test/**/*']

  s.files = FileList['lib/**/*.rb', 'README', 'doc/**/*.*', 'bin/**/*.*']
  s.require_paths << 'lib'

  s.bindir = "bin"
  s.executables << "cachetastic_drb_server"
  #s.default_executable = ""
  s.add_dependency("configatron")
  s.add_dependency("mack-facets")
  #s.extensions << ""
  s.extra_rdoc_files = ["README"]
  s.has_rdoc = true
  #s.platform = "Gem::Platform::Ruby"
  #s.required_ruby_version = ">= 1.8.5"
  #s.requirements << "An ice cold beer."
  #s.requirements << "Some free time!"
  s.rubyforge_project = "magrathea"
end

# rake package
Rake::GemPackageTask.new(@gem_spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
  rm_f FileList['pkg/**/*.*']
end

# rake
desc "Run test code"
Rake::TestTask.new(:default) do |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc "Install the gem"
task :install => [:package] do |t|
  sudo = ENV['SUDOLESS'] == 'true' || RUBY_PLATFORM =~ /win32|cygwin/ ? '' : 'sudo'
  puts `#{sudo} gem install #{File.join("pkg", @gem_spec.name)}-#{@gem_spec.version}.gem --no-update-sources`
end

desc "Release the gem"
task :release => :install do |t|
  begin
    ac_path = File.join(ENV["HOME"], ".rubyforge", "auto-config.yml")
    if File.exists?(ac_path)
      fixed = File.open(ac_path).read.gsub("  ~: {}\n\n", '')
      fixed.gsub!(/    !ruby\/object:Gem::Version \? \n.+\n.+\n\n/, '')
      puts "Fixing #{ac_path}..."
      File.open(ac_path, "w") {|f| f.puts fixed}
    end
    begin
      rf = RubyForge.new
      rf.configure
      rf.login
      rf.add_release(@gem_spec.rubyforge_project, @gem_spec.name, @gem_spec.version, File.join("pkg", "#{@gem_spec.name}-#{@gem_spec.version}.gem"))
    rescue Exception => e
      if e.message.match("Invalid package_id") || e.message.match("no <package_id> configured for")
        puts "You need to create the package!"
        rf.create_package(@gem_spec.rubyforge_project, @gem_spec.name)
        rf.add_release(@gem_spec.rubyforge_project, @gem_spec.name, @gem_spec.version, File.join("pkg", "#{@gem_spec.name}-#{@gem_spec.version}.gem"))
      else
        raise e
      end
    end
  rescue Exception => e
    if e.message == "You have already released this version."
      puts e
    else
      raise e
    end
  end
end


Rake::RDocTask.new do |rd|
  rd.main = "README"
  files = Dir.glob("**/*.rb")
  files = files.collect {|f| f unless f.match("test/") || f.match("doc/") }.compact
  files << "README"
  rd.rdoc_files = files
  rd.rdoc_dir = "doc"
  rd.options << "--line-numbers"
  rd.options << "--inline-source"
  rd.title = "cachetastic"
end
