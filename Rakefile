require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'find'
require 'rubyforge'
require 'rubygems'
require 'rubygems/gem_runner'
require 'spec'
require 'spec/rake/spectask'

@gem_spec = Gem::Specification.new do |s|
  s.name = "cachetastic"
  s.version = "3.0.2"
  s.summary = "A very simple, yet very powerful caching framework for Ruby."
  s.description = "A very simple, yet very powerful caching framework for Ruby."
  s.author = "Mark Bates"
  s.email = "mark@mackframework.com"
  s.homepage = "http://www.metabates.com"
  
  s.files = FileList['lib/**/*.*', 'README', 'LICENSE', 'bin/**/*.*']
  s.require_paths = ['lib']
  s.extra_rdoc_files = ["README", 'LICENSE']
  s.has_rdoc = true
  s.rubyforge_project = "magrathea"
  
  s.add_dependency('configatron', '>=2.3.2')
  s.add_dependency('memcache-client', '>=1.7.4')
  s.add_dependency('activesupport', '>=2.3.2')
  # s.test_files = FileList['spec/**/*']
  #s.bindir = "bin"
  #s.executables << "cachetastic"
  #s.add_dependency("", "")
  #s.add_dependency("", "")
  #s.extensions << ""
  #s.required_ruby_version = ">= 1.8.6"
  #s.default_executable = ""
  #s.platform = "Gem::Platform::Ruby"
  #s.requirements << "An ice cold beer."
  #s.requirements << "Some free time!"
end

# rake package
Rake::GemPackageTask.new(@gem_spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
  rm_f FileList['pkg/**/*.*']
end

# rake
desc 'Run specifications'
Spec::Rake::SpecTask.new(:default) do |t|
  opts = File.join(File.dirname(__FILE__), "spec", 'spec.opts')
  t.spec_opts << '--options' << opts if File.exists?(opts)
  t.spec_files = Dir.glob('spec/**/*_spec.rb')
end

desc 'Run Rcov'
task :rcov do
  unless PLATFORM['i386-mswin32'] 
    rcov = "rcov --sort coverage --rails --aggregate coverage.data " + 
    "--text-summary -Ilib -T -x gems/*,rcov*,lib/tasks/*,Rakefile,spec/*" 
  else 
    rcov = "rcov.cmd --sort coverage --rails --aggregate coverage.data " + 
    "--text-summary -Ilib -T" 
  end
  system rcov
  unless PLATFORM['i386-mswin32'] 
    system "open coverage/index.html"
  end
end

desc 'regenerate the gemspec'
task :gemspec do
  @gem_spec.version = "#{@gem_spec.version}.#{Time.now.strftime('%Y%m%d%H%M%S')}"
  File.open(File.join(File.dirname(__FILE__), 'cachetastic.gemspec'), 'w') {|f| f.puts @gem_spec.to_ruby}
end

desc "Install the gem"
task :install => [:package] do |t|
  sudo = ENV['SUDOLESS'] == 'true' || RUBY_PLATFORM =~ /win32|cygwin/ ? '' : 'sudo'
  puts `#{sudo} gem install #{File.join("pkg", @gem_spec.name)}-#{@gem_spec.version}.gem --no-update-sources --no-ri --no-rdoc`
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
  files = Dir.glob("lib/**/*.rb")
  files = files.collect {|f| f unless f.match("spec/") || f.match("doc/") }.compact
  files << "README"
  files << "LICENSE"
  rd.rdoc_files = files
  rd.rdoc_dir = "doc"
  rd.options << "--line-numbers"
  rd.options << "--inline-source"
  rd.title = "cachetastic"
end
