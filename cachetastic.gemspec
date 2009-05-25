# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cachetastic-three}
  s.version = "2.9.9.20090525090948"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Bates"]
  s.date = %q{2009-05-25}
  s.description = %q{A very simple, yet very powerful caching framework for Ruby.}
  s.email = %q{mark@mackframework.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/cachetastic/adapters/base.rb", "lib/cachetastic/adapters/file.rb", "lib/cachetastic/adapters/local_memory.rb", "lib/cachetastic/adapters/memcached.rb", "lib/cachetastic/cache.rb", "lib/cachetastic/cacheable.rb", "lib/cachetastic/extensions/string.rb", "lib/cachetastic/logger.rb", "lib/cachetastic/store_object.rb", "lib/cachetastic.rb", "README"]
  s.has_rdoc = true
  s.homepage = %q{http://www.mackframework.com}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cachetastic}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A very simple, yet very powerful caching framework for Ruby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<configatron>, [">= 2.3.0"])
      s.add_runtime_dependency(%q<memcache-client>, [">= 1.5.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.2"])
    else
      s.add_dependency(%q<configatron>, [">= 2.3.0"])
      s.add_dependency(%q<memcache-client>, [">= 1.5.0"])
      s.add_dependency(%q<activesupport>, [">= 2.2.2"])
    end
  else
    s.add_dependency(%q<configatron>, [">= 2.3.0"])
    s.add_dependency(%q<memcache-client>, [">= 1.5.0"])
    s.add_dependency(%q<activesupport>, [">= 2.2.2"])
  end
end
